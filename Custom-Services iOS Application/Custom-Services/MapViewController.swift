//
//  MapViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 13/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

// The class used for providind the functionalitites of the map ViewControler
class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, PopoverFiltersProtocol, OffersModelProtocol, GMSMapViewDelegate {

    @IBOutlet weak var dropdownMenuButton: DropMenuButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var navigationLogo: UIImageView!
    
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
    
    // Function called upon the completion of the loading
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        offersModel.delegate = self
        self.initializeDropdown()
        searchBar.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        if let currentLocation = locationManager.location {
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.camera = GMSCameraPosition.camera(withTarget: currentLocation.coordinate , zoom: 12.0)
        }
    }
    
    // Function called upon the completion of the view's rendering
    override func viewWillAppear(_ animated: Bool) {
        searchOn = false
        searchBar.text = ""
        customizeAppearance()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if UserDefaults.standard.bool(forKey: "hasCategories") == true {
            categories = UserDefaults.standard.value(forKey: "categories")! as! [String]
            offersModel.requestOffers(hasCategories: true)
        } else {
            offersModel.requestOffers(hasCategories: false)
        }
    }
    
    // Function called when the view is about to disappear
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        offers = []
        filteredOffers = []
    }
    
    // Function that performs the customisation of the visual elements
    func customizeAppearance() {
        navigationView.backgroundColor = Utils.instance.mainColour
        mainTitleLabel.text = Utils.instance.mainTitle
        if Utils.instance.navigationLogo != "" {
            let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(Utils.instance.navigationLogo)").path
            navigationLogo.image = UIImage(contentsOfFile: filename)
        } else {
            navigationLogo.image = UIImage(named: "banWhite")
        }
    }
    
    // Functions that manage the search bar by reloading the table with only the elements that match the search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchOn = (searchBar.text != nil && searchBar.text != "") ? true : false
        filteredOffers = offers.filter({ (offer) -> Bool in
            return offer.name!.lowercased().range(of: searchText.lowercased()) != nil;
        })
        populateMap()
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
        populateMap()
        searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "mapFiltersViewController") {
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
    
    func offersReceived(_ receivedOffers: [[String:Any]]) {
        var offersAux: [OfferModel] = []
        var item:OfferModel;
        
        // parse the received JSON and save the contacts
        for i in 0 ..< receivedOffers.count {
            
            if let offerId = Int((receivedOffers[i]["offer_id"] as? String)!),
                let locationId = Int((receivedOffers[i]["location_id"] as? String)!),
                let name = receivedOffers[i]["name"] as? String,
                let address = receivedOffers[i]["address"] as? String,
                let about = receivedOffers[i]["about"] as? String,
                let discount = Float((receivedOffers[i]["discount"] as? String)!),
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
                item.address = address
                item.about = about
                item.rating = Float(rating)
                item.discount = Float(discount)
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
                
                if let appointmentDuration = receivedOffers[i]["appointment_minute_duration"] as? String {
                    item.appointmentDuration = Int(appointmentDuration)
                } else {
                    item.appointmentDuration = -1
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
                        if let url = URL(string: "\(Utils.serverAddress)/resources/vendor_images/\(logoImage)") {
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
                        if let url = URL(string: "\(Utils.serverAddress)/resources/vendor_images/\(offerImage)") {
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
    
    // Functions delegated by the offer cells upon pressing the favourite button
    func favouriteSelected(_ result: NSString, tag: Int) {}
    
    func reloadTable() {
        if (UserDefaults.standard.value(forKey: "storedOffers") != nil) {
            if let data = UserDefaults.standard.data(forKey: "storedOffers"),
                let offersAux = NSKeyedUnarchiver.unarchiveObject(with: data) as? [OfferModel] {
                offers = offersAux
            }
        }
        offers = Utils.instance.filterOffers(offers: offers, distance: maxDistance, minTime: minTime, maxTime: maxTime, sortBy: sortBy, onlyAvailableOffers: onlyAvailableOffers, allCategories: allCategories, allowedCategories: allowedCategories)
        offers = Utils.instance.sortOffers(offers: offers, sortBy: 0)
        offers = Utils.instance.removeDuplicateLocations(offers: offers, onlyAvailableOffers: onlyAvailableOffers)
        offers = Utils.instance.sortOffers(offers: offers, sortBy: sortBy)
        populateMap()
    }
    
    func refreshTable() {
        // Code to refresh table view
        if UserDefaults.standard.bool(forKey: "hasCategories") == true {
            offersModel.requestOffers(hasCategories: true)
        } else {
            offersModel.requestOffers(hasCategories: false)
        }
    }
    
    func populateMap() {
        mapView.clear()
        for offer in searchOn ? filteredOffers : offers {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(offer.latitude!), longitude: CLLocationDegrees(offer.longitude!))
            marker.infoWindowAnchor = CGPoint(x: 0.5, y:0)
            marker.accessibilityLabel = "\(searchOn ? filteredOffers.index(of: offer)! : offers.index(of: offer)!)"
            marker.map = mapView
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let locationDetailsViewController = (self.storyboard?.instantiateViewController(withIdentifier: "locationDetailsViewController"))! as! LocationDetailsViewController
        locationDetailsViewController.locationId = searchOn ? filteredOffers[Int(marker.accessibilityLabel!)!].locationId! : offers[Int(marker.accessibilityLabel!)!].locationId!
        locationDetailsViewController.favourite = searchOn ? filteredOffers[Int(marker.accessibilityLabel!)!].favourite! : offers[Int(marker.accessibilityLabel!)!].favourite!
        self.navigationController?.pushViewController(locationDetailsViewController , animated: true)
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        searchBar.resignFirstResponder()
        let index:Int! = Int(marker.accessibilityLabel!)
        let item: OfferModel = searchOn ? filteredOffers[index] : offers[index]
        
        let mapMarkerView = Bundle.main.loadNibNamed("MapMarkerView", owner: self, options: nil)?[0] as! MapMarkerView
        mapMarkerView.layer.cornerRadius = 10
        mapMarkerView.layer.borderWidth = 1
        mapMarkerView.layer.borderColor = UIColor.lightGray.cgColor
        mapMarkerView.layer.shadowColor = UIColor.lightGray.cgColor
        mapMarkerView.layer.shadowOffset = CGSize(width:-2, height:2)
        mapMarkerView.layer.shadowRadius = 3
        mapMarkerView.layer.shadowOpacity = 0.6
        mapMarkerView.layer.masksToBounds = false
        mapMarkerView.clipsToBounds = false
        mapMarkerView.titleLabel.text = item.name!
        mapMarkerView.timeIntervalLabel.text = "\(item.minTime!) - \(item.maxTime!)"
        mapMarkerView.ratingLabel.text = "\(String(format: "%.1f", item.rating!))"
        
        if UserDefaults.standard.value(forKey: "type") as! String == "location" {
            if item.discountRange != nil && item.discountRange != "" {
                mapMarkerView.discountLabel.text = "\(item.discountRange!)% OFF"
            } else {
                mapMarkerView.discountLabel.text = "\(Int(item.discount!))% OFF"
            }
        } else {
            if item.discountRange != nil && item.discountRange != "" {
                mapMarkerView.discountLabel.text = "\(item.discountRange!) GBP"
            } else {
                mapMarkerView.discountLabel.text = "\(item.discount!) GBP"
            }
        }
        
        if item.offerLogo! != "" {
            let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(item.offerLogo!)").path
            mapMarkerView.logoImage.image = UIImage(contentsOfFile: filename)
        } else {
            mapMarkerView.logoImage.image = UIImage(named: "ban")
        }
        return mapMarkerView
    }
    
    // Function that initiates the DropMenuButton dropdown menu
    // source: https://github.com/HacktechSolutions/Swift3.0-Dropdown-Menu
    func initializeDropdown() {
        if UserDefaults.standard.value(forKey: "type") as! String == "location" {
            dropdownMenuButton.initMenu(["View Profile", "Sign Out"], actions: [
                ({ () -> (Void) in
                    self.performSegue(withIdentifier: "mapProfileViewController", sender: nil)
                }),
                ({ () -> (Void) in
                    self.signOut(Any.self)
                })])
        } else {
            dropdownMenuButton.initMenu(["View Profile", "View Receipts", "Sign Out"], actions: [
                ({ () -> (Void) in
                    self.performSegue(withIdentifier: "mapProfileViewController", sender: nil)
                }),
                ({ () -> (Void) in
                    self.performSegue(withIdentifier: "mapReceiptsViewController", sender: nil)
                }),
                ({ () -> (Void) in
                    self.signOut(Any.self)
                })])
        }
    }
    
    func signOut(_ sender: Any) {
        Utils.instance.signOut()
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(show: true, notification: notification)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(show: false, notification: notification)
    }
    
    // Function called upon the appearance of the keyboard in order to adjust the view height
    // source: http://truelogic.org/wordpress/2016/04/15/swift-moving-uitextfield-up-when-keyboard-is-shown/
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
    }

    func dismissKeyboard(gestureRecognizer: UITapGestureRecognizer) {
        if !self.dropdownMenuButton.table.frame.contains(gestureRecognizer.location(in: self.view)) && !self.dropdownMenuButton.frame.contains(gestureRecognizer.location(in: self.view)) {
            dropdownMenuButton.hideMenu()
        }
        view.endEditing(true)
    }
}
