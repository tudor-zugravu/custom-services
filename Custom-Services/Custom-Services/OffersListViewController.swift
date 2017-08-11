//
//  VendorsListViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 01/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import CoreLocation

class OffersListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate , OfferListCellProtocol, PopoverFiltersProtocol, OffersModelProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dropdownMenuButton: DropMenuButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var categories: [String] = []
    let offersModel = OffersModel()
    var offers: [OfferModel] = []
    var filteredOffers: [OfferModel] = []
    var maxDistance: Int = 50
    var minTime: String = "08:00"
    var maxTime: String = "24:00"
    var sortBy: Int = 0
    var onlyAvailableOffers: Bool = true
    var allCategories: Bool = true
    var allowedCategories: [String] = []
    var searchOn : Bool = false
    let locationManager = CLLocationManager()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offersModel.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to reload offers")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        self.initializeDropdown()
        searchBar.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchOn = false
        searchBar.text = ""
        
        // Adding the gesture recognizer that will dismiss the keyboard on an exterior tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // COPIED
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if UserDefaults.standard.bool(forKey: "hasCategories") == true {
            categories = UserDefaults.standard.value(forKey: "categories")! as! [String]
            offersModel.requestOffers(hasCategories: true)
        } else {
            offersModel.requestOffers(hasCategories: false)
        }
    }
    
    // COPIED
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        offers = []
        filteredOffers = []
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchOn = (searchBar.text != nil && searchBar.text != "") ? true : false
        filteredOffers = offers.filter({ (offer) -> Bool in
            return offer.name!.lowercased().range(of: searchText.lowercased()) != nil;
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
        return searchOn ? filteredOffers.count : offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "offersCell") as? OffersTableViewCell else {
            return OffersTableViewCell()
        }
        cell.delegate = self
        cell.tag = indexPath.row
        
        let item: OfferModel = searchOn ? filteredOffers[indexPath.row] : offers[indexPath.row]
        cell.configureCell(item.name!, rating: item.rating!, distance: item.distance!, discount:item.discount!, minTime:item.minTime!, maxTime:item.maxTime!, offerImage:item.offerImage!, offerLogo:item.offerLogo!, favourite:item.favourite!, quantity: item.quantity!, discountRange: item.discountRange)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didPressFavouriteButton(_ tag: Int) {
        offersModel.sendFavourite(locationId: offers[tag].locationId!, favourite: offers[tag].favourite! ? 0 : 1, tag: tag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "offersFiltersViewController") {
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
    
    func favouriteSelected(_ result: NSString, tag: Int) {
        if result == "1" {
            offers[tag].favourite = offers[tag].favourite! ? false : true
        }
    }
    
    func offersReceived(_ receivedOffers: [[String:Any]]) {
        var offersAux: [OfferModel] = []
        var item:OfferModel;
        
        // parse the received JSON and save the contacts
        for i in 0 ..< receivedOffers.count {
            
            if let offerId = Int((receivedOffers[i]["offer_id"] as? String)!),
                let locationId = Int((receivedOffers[i]["location_id"] as? String)!),
                let name = receivedOffers[i]["name"] as? String,
                let discount = Int((receivedOffers[i]["discount"] as? String)!),
                let startingTime = receivedOffers[i]["starting_time"] as? String,
                let endingTime = receivedOffers[i]["ending_time"] as? String,
                let rating = Float((receivedOffers[i]["rating"] as? String)!),
                let latitude = Double((receivedOffers[i]["latitude"] as? String)!),
                let longitude = Double((receivedOffers[i]["longitude"] as? String)!)
            {
                item = OfferModel()
                item.id = offerId
                item.locationId = locationId
                item.name = name
                item.rating = Float(rating)
                item.discount = Int(discount)
                item.minTime = Utils.instance.trimSeconds(time: startingTime)
                item.maxTime = Utils.instance.trimSeconds(time: endingTime)
                item.latitude = Double(latitude)
                item.longitude = Double(longitude)
                
                if UserDefaults.standard.bool(forKey: "hasCategories") == true {
                    if let category = receivedOffers[i]["category"] as? String {
                        item.category = category
                    }
                }
                
                if let quantity = receivedOffers[i]["quantity"] as? String {
                    item.quantity = Int(quantity)
                } else {
                    item.quantity = -1
                }
                
                if let favourite = receivedOffers[i]["favourite"] as? String {
                        item.favourite = favourite == "1" ? true : false
                } else {
                    item.favourite = false
                }

                if let logoImage = receivedOffers[i]["logo_image"] as? String {
                    
                    let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(logoImage)")
                    if FileManager.default.fileExists(atPath: filename.path) {
                        item.offerLogo = logoImage
                    } else {
                        // Download the profile picture, if exists
                        if let url = URL(string: "http://46.101.29.197/vendor_images/\(logoImage)") {
                            if let data = try? Data(contentsOf: url) {
                                var logoImg: UIImage
                                logoImg = UIImage(data: data)!
                                if let data = UIImagePNGRepresentation(logoImg) {
                                    try? data.write(to: filename)
                                    item.offerLogo = logoImage
                                } else {
                                    item.offerLogo = ""
                                }
                            } else {
                                item.offerLogo = ""
                            }
                        }
                    }
                } else {
                    item.offerLogo = ""
                }
                
                if let offerImage = receivedOffers[i]["image"] as? String {
                    
                    let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(offerImage)")
                    if FileManager.default.fileExists(atPath: filename.path) {
                        item.offerImage = offerImage
                    } else {
                        // Download the profile picture, if exists
                        if let url = URL(string: "http://46.101.29.197/vendor_images/\(offerImage)") {
                            if let data = try? Data(contentsOf: url) {
                                var offerImg: UIImage
                                offerImg = UIImage(data: data)!
                                if let data = UIImagePNGRepresentation(offerImg) {
                                    try? data.write(to: filename)
                                    item.offerImage = offerImage
                                } else {
                                    item.offerImage = ""
                                }
                            } else {
                                item.offerImage = ""
                            }
                        }
                    }
                } else {
                    item.offerImage = ""
                }
                
                offersAux.append(item)
            }
        }
        offers = offersAux
        
        if let currentLocation = locationManager.location {
            for offer in offers {
                offer.setDistance(location: currentLocation)
            }
        }
        
        let storedOffers = NSKeyedArchiver.archivedData(withRootObject: offers)
        UserDefaults.standard.set(storedOffers, forKey:"storedOffers");
        
        reloadTable()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func didChangeFiltersAllCategories(distance: Int, lowerTimeInterval: String, higherTimeInterval: String, sortBy: Int, onlyAvailableOffers: Bool) {

        self.maxDistance = distance
        self.minTime = lowerTimeInterval
        self.maxTime = higherTimeInterval
        self.sortBy = sortBy
        self.onlyAvailableOffers = onlyAvailableOffers
        self.allCategories = true
        if UserDefaults.standard.bool(forKey: "hasCategories") == true {
            offersModel.requestOffers(hasCategories: true)
        } else {
            offersModel.requestOffers(hasCategories: false)
        }
    }
    
    func didChangeFiltersSomeCategories(distance: Int, lowerTimeInterval: String, higherTimeInterval: String, sortBy: Int, onlyAvailableOffers: Bool, categories: [String]) {
        
        self.maxDistance = distance
        self.minTime = lowerTimeInterval
        self.maxTime = higherTimeInterval
        self.sortBy = sortBy
        self.onlyAvailableOffers = onlyAvailableOffers
        self.allCategories = false
        self.allowedCategories = categories
        offersModel.requestOffers(hasCategories: true)
    }
    
    func reloadTable() {
        if (UserDefaults.standard.value(forKey: "storedOffers") != nil) {
            if let data = UserDefaults.standard.data(forKey: "storedOffers"),
                let offersAux = NSKeyedUnarchiver.unarchiveObject(with: data) as? [OfferModel] {
                offers = offersAux
            }
        }
        offers = Utils.instance.filterOffers(offers: offers, distance: maxDistance, minTime: minTime, maxTime: maxTime, sortBy: sortBy, onlyAvailableOffers: onlyAvailableOffers, allCategories: allCategories, allowedCategories: allowedCategories)
        offers = Utils.instance.sortOffers(offers: offers, sortBy: 0)
        offers = Utils.instance.removeDuplicateLocations(offers: offers)
        offers = Utils.instance.sortOffers(offers: offers, sortBy: sortBy)
        tableView.reloadData()
    }
    
    func refreshTable() {
        // Code to refresh table view
        if UserDefaults.standard.bool(forKey: "hasCategories") == true {
            offersModel.requestOffers(hasCategories: true)
        } else {
            offersModel.requestOffers(hasCategories: false)
        }
    }
    
    // Create the dropdown menu
    func initializeDropdown() {
        dropdownMenuButton.initMenu(["View Profile", "Contact Us", "Sign Out"], actions: [
            ({ () -> (Void) in
//                let nextView:UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "changePWD"))!
//                self.navigationController?.pushViewController(nextView , animated: true)
                self.performSegue(withIdentifier: "offersProfileViewController", sender: nil)
            }),
            ({ () -> (Void) in print("CONTACT US!") }),
            ({ () -> (Void) in
                self.signOut(Any.self) 
            })])
    }

    func signOut(_ sender: Any) {
        
        Utils.instance.signOut()
        _ = self.navigationController?.popToRootViewController(animated: true)
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
    func dismissKeyboard(gestureRecognizer: UITapGestureRecognizer) {
        if !self.dropdownMenuButton.table.frame.contains(gestureRecognizer.location(in: self.view)) && !self.dropdownMenuButton.frame.contains(gestureRecognizer.location(in: self.view)) {
            dropdownMenuButton.hideMenu()
        }
        view.endEditing(true)
    }
}
