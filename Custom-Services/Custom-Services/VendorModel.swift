//
//  VendorModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 01/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class VendorModel: NSObject {

    //properties
    var name: String?
    var rating: String?
    var distance: String?
    var price: String?
    var time: String?
    var vendorPicture: String?
    var vendorLogo: String?
    var favourite: Bool?
    var finished: Int?
    
    //empty constructor
    override init()
    {
        
    }
    
    //construct with @name, @email and @telephone parameters
    init(name: String, rating: String, distance: String, price: String, time: String, vendorPicture: String, vendorLogo: String, favourite: Bool, finished: Int) {
        
        self.name = name
        self.rating = rating
        self.distance = distance
        self.price = price
        self.time = time
        self.vendorPicture = vendorPicture
        self.vendorLogo = vendorLogo
        self.favourite = favourite
        self.finished = finished
    }
    
    
    //prints object's current state
    override var description: String {
        return "Name: \(String(describing: name)), Rating: \(String(describing: rating)), Distance: \(String(describing: distance)), Price: \(String(describing: price)), Time: \(String(describing: time)), VendorPicture: \(String(describing: vendorPicture)), VendorLogo: \(String(describing: vendorLogo)), Favourite: \(String(describing: favourite)), Finished: \(String(describing: finished))"
    }
}
