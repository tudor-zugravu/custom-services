//
//  VendorsListViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 01/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import CoreLocation

class VendorsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate , VendorListCellProtocol, PopoverFiltersProtocol, OffersModelProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dropdownMenuButton: DropMenuButton!
    @IBOutlet weak var dropdownFilterButton: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // Customize here
    var dbVendors: [VendorModel] = []
    var categories: [String] = []
    let offersModel = OffersModel()
    
    var vendors: [VendorModel] = []
    var filteredVendors: [VendorModel] = []
    var maxDistance: Int = 50
    var minTime: String = "08:00"
    var maxTime: String = "24:00"
    var sortBy: Int = 0
    var onlyAvailableOffers: Bool = true
    var allCategories: Bool = true
    var allowedCategories: [String] = []
    var searchOn : Bool = false
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offersModel.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        self.initializeDropdown()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        categories = UserDefaults.standard.value(forKey: "categories")! as! [String]
        
        dbVendors.append(VendorModel(id: 0, name: "St. Christopher's Inn", rating: 4.5, latitude: 51.502839, longitude: -0.091894, price: 3, minTime: "18:00", maxTime: "20:30", vendorPicture: "stChristopherImage", vendorLogo: "stChristopherLogo", favourite: true, finished: 0, category: "Pubs"))
        dbVendors.append(VendorModel(id: 1, name: "The George Inn", rating: 5, latitude: 51.504176, longitude: -0.089994, price: 4, minTime: "16:00", maxTime: "20:00", vendorPicture: "theGeorgeImage", vendorLogo: "theGeorgeLogo", favourite: true, finished: 0, category: "Bars"))
        dbVendors.append(VendorModel(id: 2, name: "The Sadler's Pub", rating: 3.5, latitude: 51.715760, longitude: -1.221712, price: 3.5, minTime: "20:00", maxTime: "22:00", vendorPicture: "theSadlersImage", vendorLogo: "theSadlersLogo", favourite: false, finished: 0, category: "Pubs"))
        dbVendors.append(VendorModel(id: 3, name: "The Blue Bar", rating: 4, latitude: 51.502064, longitude: -0.156193, price: 4, minTime: "20:30", maxTime: "22:30", vendorPicture: "theBlueBarImage", vendorLogo: "theBlueBarLogo", favourite: false, finished: 0, category: "Pubs"))
       
        if let currentLocation = locationManager.location {
            for vendor in dbVendors {
                vendor.setDistance(location: currentLocation)
            }
        }
        
        reloadTable()
        
        offersModel.requestOffers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchOn = false
        searchBar.text = ""
        
        // Adding the gesture recognizer that will dismiss the keyboard on an exterior tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // COPIED
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // COPIED
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchOn = (searchBar.text != nil && searchBar.text != "") ? true : false
        filteredVendors = vendors.filter({ (vendor) -> Bool in
            return vendor.name!.lowercased().range(of: searchText.lowercased()) != nil;
        })
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchOn = (searchBar.text != nil && searchBar.text != "") ? true : false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchOn = (searchBar.text != nil && searchBar.text != "") ? true : false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchOn = true
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchOn = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return searchOn ? filteredVendors.count : vendors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "vendorsCell") as? VendorsTableViewCell else {
            return VendorsTableViewCell()
        }
        cell.delegate = self
        cell.tag = indexPath.row

        let item: VendorModel = searchOn ? filteredVendors[indexPath.row] : vendors[indexPath.row]
        cell.configureCell(item.name!, rating: item.rating!, distance: item.distance, price:item.price!, minTime:item.minTime!, maxTime:item.maxTime!, vendorPicture:item.vendorPicture!, vendorLogo:item.vendorLogo!, favourite:item.favourite!, finished: item.finished!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didPressFavouriteButton(_ tag: Int) {
        vendors[tag].favourite = vendors[tag].favourite! ? false : true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowPopoverFiltersViewController") {
            let popoverFiltersViewController = segue.destination as! PopoverFiltersViewController
            popoverFiltersViewController.delegate = self

            popoverFiltersViewController.categories = categories
            popoverFiltersViewController.minTime = minTime
            popoverFiltersViewController.maxTime = maxTime
            popoverFiltersViewController.maxDistance = maxDistance
            popoverFiltersViewController.sortBy = sortBy
            popoverFiltersViewController.onlyAvailableOffers = onlyAvailableOffers
            popoverFiltersViewController.selections = Array(repeating: false, count: categories.count)
            
            if categories.count > 1 {
                popoverFiltersViewController.allCategories = allCategories
                if !allCategories {
                    popoverFiltersViewController.noSelections = allowedCategories.count
                    for (index,category) in categories.enumerated() {
                        if allowedCategories.contains(category) {
                            popoverFiltersViewController.selections[index] = true
                        } else {
                            popoverFiltersViewController.selections[index] = false
                        }
                    }
                }
            }
        }
    }
    
    func offersReceived(_ offers: [[String:Any]]) {
        print(offers[0])
        
//        var offersAux: [ContactModel] = []
//        var item:ContactModel;
//        
//        // parse the received JSON and save the contacts
//        for i in 0 ..< contactDetails.count {
//            
//            if let username = contactDetails[i]["username"] as? String,
//                let name = contactDetails[i]["name"] as? String,
//                let email = contactDetails[i]["email"] as? String,
//                let phoneNo = contactDetails[i]["phone_number"] as? String,
//                let userId = contactDetails[i]["user_id"] as? Int,
//                let contactId = contactDetails[i]["contact_id"] as? Int
//            {
//                item = ContactModel()
//                item.username = username
//                item.name = name
//                item.email = email
//                item.phoneNo = phoneNo
//                item.userId = userId
//                item.contactId = contactId
//                item.phoneNo = phoneNo
//                
//                if let about = contactDetails[i]["biography"] as? String {
//                    item.about = about
//                } else {
//                    item.about = ""
//                }
//                
//                if let profilePicture = contactDetails[i]["profile_picture"] as? String {
//                    
//                    let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(profilePicture)")
//                    if FileManager.default.fileExists(atPath: filename.path) {
//                        item.profilePicture = profilePicture
//                    } else {
//                        // Download the profile picture, if exists
//                        if let url = URL(string: "http://188.166.157.62/profile_pictures/\(profilePicture)") {
//                            if let data = try? Data(contentsOf: url) {
//                                var profileImg: UIImage
//                                profileImg = UIImage(data: data)!
//                                if let data = UIImagePNGRepresentation(profileImg) {
//                                    try? data.write(to: filename)
//                                    item.profilePicture = profilePicture
//                                } else {
//                                    item.profilePicture = ""
//                                }
//                            } else {
//                                item.profilePicture = ""
//                            }
//                        }
//                    }
//                } else {
//                    item.profilePicture = ""
//                }
//                
//                contactsAux.append(item)
//            }
//        }
//        contacts = contactsAux
//        
//        let storedContacts = NSKeyedArchiver.archivedData(withRootObject: contacts)
//        UserDefaults.standard.set(storedContacts, forKey:"contacts");
//        
//        self.tableView.reloadData()
        
        
    }
    
    func didChangeFiltersAllCategories(distance: Int, lowerTimeInterval: String, higherTimeInterval: String, sortBy: Int, onlyAvailableOffers: Bool) {

        self.maxDistance = distance
        self.minTime = lowerTimeInterval
        self.maxTime = higherTimeInterval
        self.sortBy = sortBy
        self.onlyAvailableOffers = onlyAvailableOffers
        self.allCategories = true
        reloadTable()
    }
    
    func didChangeFiltersSomeCategories(distance: Int, lowerTimeInterval: String, higherTimeInterval: String, sortBy: Int, onlyAvailableOffers: Bool, categories: [String]) {
        
        self.maxDistance = distance
        self.minTime = lowerTimeInterval
        self.maxTime = higherTimeInterval
        self.sortBy = sortBy
        self.onlyAvailableOffers = onlyAvailableOffers
        self.allCategories = false
        self.allowedCategories = categories
        reloadTable()
    }
    
    func reloadTable() {
        vendors = Utils.instance.filterVendors(vendors: dbVendors, distance: maxDistance, minTime: minTime, maxTime: maxTime, sortBy: sortBy, onlyAvailableOffers: onlyAvailableOffers, allCategories: allCategories, allowedCategories: allowedCategories)
        tableView.reloadData()
    }
    
    // Create the dropdown menu
    func initializeDropdown() {
        dropdownMenuButton.initMenu(["View Profile", "Contact Us", "Sign Out"], actions: [
            ({ () -> (Void) in print("PROFILE!") }),
            ({ () -> (Void) in print("CONTACT US!") }),
            ({ () -> (Void) in print("SIGN OUT!") })])
    }
    
    // COPIED
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(show: true, notification: notification)
    }
    
    // COPIED
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(show: false, notification: notification)
    }
    
    // COPIED
    func adjustingHeight(show:Bool, notification:NSNotification) {
        if let userInfo = notification.userInfo, let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] {
            let duration = (durationValue as AnyObject).doubleValue
            let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            let options = UIViewAnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            
            self.bottomConstraint.constant = (keyboardFrame.height  - 50) * (show ? 1 : 0)
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        reloadTable()
    }
    
    // Called to dismiss the keyboard from the screen
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
