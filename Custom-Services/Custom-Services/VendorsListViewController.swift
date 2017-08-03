//
//  VendorsListViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 01/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class VendorsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, VendorListCellProtocol, PopoverFiltersProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dropdownMenuButton: DropMenuButton!
    @IBOutlet weak var dropdownFilterButton: UILabel!
    
    var vendors: [VendorModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.dropInit()
        
        vendors.append(VendorModel(name: "St. Christopher's Inn", rating: "4.5", distance: "313 m", price: "3 GBP", time: "18:00 - 20:30", vendorPicture: "stChristopherImage", vendorLogo: "stChristopherLogo", favourite: true, finished: 0))
        vendors.append(VendorModel(name: "The George Inn", rating: "5", distance: "56 m", price: "4 GBP", time: "16:00 - 20:00", vendorPicture: "theGeorgeImage", vendorLogo: "theGeorgeLogo", favourite: true, finished: 1))
        vendors.append(VendorModel(name: "The Sadler's Pub", rating: "3.5", distance: "1200 m", price: "3.5 GBP", time: "20:00 - 22:00", vendorPicture: "theSadlersImage", vendorLogo: "theSadlersLogo", favourite: false, finished: 0))
        vendors.append(VendorModel(name: "The Blue Bar", rating: "4", distance: "641 m", price: "4 GBP", time: "20:30 - 22:30", vendorPicture: "theBlueBarImage", vendorLogo: "theBlueBarLogo", favourite: false, finished: 2))
        tableView.reloadData()
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
            
            cell.configureCell(item.name!, rating: item.rating!, distance: item.distance!, price:item.price!, time:item.time!, vendorPicture:item.vendorPicture!, vendorLogo:item.vendorLogo!, favourite:item.favourite!, finished: item.finished!)
            
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
    
    func didChangeFiltersAllCategories(distance: Int, lowerTimeInterval: String, higherTimeInterval: String, onlyAvailableOffers: Bool) {
        print("AllCategories: \(distance) \(lowerTimeInterval):\(higherTimeInterval)")
    }
    
    func didChangeFiltersSomeCategories(distance: Int, lowerTimeInterval: String, higherTimeInterval: String, onlyAvailableOffers: Bool, categories: [String]) {
        print("SomeCategories: \(distance) \(lowerTimeInterval):\(higherTimeInterval) \(categories)")
    }
    
    //Dropdown menu Initinal
    func dropInit() {
        dropdownMenuButton.initMenu(["View Profile", "Contact Us", "Sign Out"], actions: [
            ({ () -> (Void) in print("PROFILE!") }),
            ({ () -> (Void) in print("CONTACT US!") }),
            ({ () -> (Void) in print("SIGN OUT!") })])    }
}
