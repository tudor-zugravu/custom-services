//
//  VendorsListViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 01/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import CoreLocation

class VendorsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate , VendorListCellProtocol, PopoverFiltersProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dropdownMenuButton: DropMenuButton!
    @IBOutlet weak var dropdownFilterButton: UILabel!
    
    // Customize here
    var dbVendors: [VendorModel] = []
    
    var vendors: [VendorModel] = []
    var maxDistance: Int = 50
    var minTime: String = "08:00"
    var maxTime: String = "24:00"
    var sortBy: Int = 0
    var onlyAvailableOffers: Bool = true
    var allCategories: Bool = true
    var allowedCategories: [String] = []
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.dropInit()
        
        dbVendors.append(VendorModel(name: "St. Christopher's Inn", rating: 4.5, latitude: 51.502839, longitude: -0.091894, price: 3, minTime: "18:00", maxTime: "20:30", vendorPicture: "stChristopherImage", vendorLogo: "stChristopherLogo", favourite: true, finished: 0))
        dbVendors.append(VendorModel(name: "The George Inn", rating: 5, latitude: 51.504176, longitude: -0.089994, price: 4, minTime: "16:00", maxTime: "20:00", vendorPicture: "theGeorgeImage", vendorLogo: "theGeorgeLogo", favourite: true, finished: 1))
        dbVendors.append(VendorModel(name: "The Sadler's Pub", rating: 3.5, latitude: 51.715760, longitude: -1.221712, price: 3.5, minTime: "20:00", maxTime: "22:00", vendorPicture: "theSadlersImage", vendorLogo: "theSadlersLogo", favourite: false, finished: 0))
        dbVendors.append(VendorModel(name: "The Blue Bar", rating: 4, latitude: 51.502064, longitude: -0.156193, price: 4, minTime: "20:30", maxTime: "22:30", vendorPicture: "theBlueBarImage", vendorLogo: "theBlueBarLogo", favourite: false, finished: 2))
       
        if let currentLocation = locationManager.location {
            for vendor in dbVendors {
                vendor.setDistance(location: currentLocation)
            }
        }
        
        vendors = Utils.instance.filterVendors(vendors: dbVendors, distance: maxDistance, minTime: minTime, maxTime: maxTime, sortBy: sortBy, onlyAvailableOffers: onlyAvailableOffers, allCategories: allCategories, allowedCategories: allowedCategories)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return vendors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "vendorsCell") as? VendorsTableViewCell {
            cell.delegate = self
            cell.tag = indexPath.row

            var item: VendorModel
            item = vendors[indexPath.row]
            
            cell.configureCell(item.name!, rating: item.rating!, distance: item.distance, price:item.price!, minTime:item.minTime!, maxTime:item.maxTime!, vendorPicture:item.vendorPicture!, vendorLogo:item.vendorLogo!, favourite:item.favourite!, finished: item.finished!)
            
            return cell
        } else {
            return VendorsTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didPressFavouriteButton(_ tag: Int) {
        if (vendors[tag].favourite == true) {
            vendors[tag].favourite = false
        } else {
            vendors[tag].favourite = true
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowPopoverFiltersViewController") {
            let popoverFiltersViewController = segue.destination as! PopoverFiltersViewController
            popoverFiltersViewController.delegate = self
        }
    }
    
    func didChangeFiltersAllCategories(distance: Int, lowerTimeInterval: String, higherTimeInterval: String, sortBy: Int, onlyAvailableOffers: Bool) {

        self.maxDistance = distance
        self.minTime = lowerTimeInterval
        self.maxTime = higherTimeInterval
        self.sortBy = sortBy
        self.onlyAvailableOffers = onlyAvailableOffers
        self.allCategories = true
        
        vendors = Utils.instance.filterVendors(vendors: dbVendors, distance: maxDistance, minTime: minTime, maxTime: maxTime, sortBy: sortBy, onlyAvailableOffers: onlyAvailableOffers, allCategories: allCategories, allowedCategories: allowedCategories)
        tableView.reloadData()
    }
    
    func didChangeFiltersSomeCategories(distance: Int, lowerTimeInterval: String, higherTimeInterval: String, sortBy: Int, onlyAvailableOffers: Bool, categories: [String]) {
        
        self.maxDistance = distance
        self.minTime = lowerTimeInterval
        self.maxTime = higherTimeInterval
        self.sortBy = sortBy
        self.onlyAvailableOffers = onlyAvailableOffers
        self.allCategories = false
        self.allowedCategories = categories
        
        vendors = Utils.instance.filterVendors(vendors: dbVendors, distance: maxDistance, minTime: minTime, maxTime: maxTime, sortBy: sortBy, onlyAvailableOffers: onlyAvailableOffers, allCategories: allCategories, allowedCategories: allowedCategories)
        tableView.reloadData()
    }
    
    //Dropdown menu Initinal
    func dropInit() {
        dropdownMenuButton.initMenu(["View Profile", "Contact Us", "Sign Out"], actions: [
            ({ () -> (Void) in print("PROFILE!") }),
            ({ () -> (Void) in print("CONTACT US!") }),
            ({ () -> (Void) in print("SIGN OUT!") })])    }
}
