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
    
    //empty constructor
    override init()
    {
        
    }
    
    //construct with @name, @email and @telephone parameters
    init(name: String, rating: String, distance: String, price: String, time: String, vendorPicture: String, vendorLogo: String, favourite: Bool) {
        
        self.name = name
        self.rating = rating
        self.distance = distance
        self.price = price
        self.time = time
        self.vendorPicture = vendorPicture
        self.vendorLogo = vendorLogo
        self.favourite = favourite
    }
    
    
    //prints object's current state
    override var description: String {
        return "Name: \(name), Rating: \(rating), Distance: \(distance), Price: \(price), Time: \(time), VendorPicture: \(vendorPicture), VendorLogo: \(vendorLogo), Favourite: \(favourite)"
    }
}
