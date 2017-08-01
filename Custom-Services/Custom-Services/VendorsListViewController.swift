//
//  VendorsListViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 01/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class VendorsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var vendors: [VendorModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        vendors.append(VendorModel(name: "St. Christopher's Inn", rating: "4.5", distance: "313 m", price: "3 GBP", time: "18:00 - 20:30", vendorPicture: "stChristopherImage", vendorLogo: "stChristopherLogo", favourite: true))
        vendors.append(VendorModel(name: "The George Inn", rating: "5", distance: "56 m", price: "4 GBP", time: "16:00 - 20:00", vendorPicture: "theGeorgeImage", vendorLogo: "theGeorgeLogo", favourite: true))
        vendors.append(VendorModel(name: "The Sadler's Pub", rating: "3.5", distance: "1200 m", price: "3.5 GBP", time: "20:00 - 22:00", vendorPicture: "theSadlersImage", vendorLogo: "theSadlersLogo", favourite: false))
        vendors.append(VendorModel(name: "The Blue Bar", rating: "4", distance: "641 m", price: "4 GBP", time: "20:30 - 22:30", vendorPicture: "theBlueBarImage", vendorLogo: "theBlueBarLogo", favourite: false))
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
        print("Heheeei \(vendors.count)")
        if let cell = tableView.dequeueReusableCell(withIdentifier: "vendorsCell") as? VendorsTableViewCell {
            
            var item: VendorModel
            item = vendors[indexPath.row]
            
            cell.configureCell(item.name!, rating: item.rating!, distance: item.distance!, price:item.price!, time:item.time!, vendorPicture:item.vendorPicture!, vendorLogo:item.vendorLogo!, favourite:item.favourite!)
            
            return cell
        } else {
            return VendorsTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
