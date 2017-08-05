//
//  VendorModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 01/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import CoreLocation

class VendorModel: NSObject {

    //properties
    var id: Int?
    var name: String?
    var rating: Float?
    var distance: Int = 0
    var latitude: Double?
    var longitude: Double?
    var price: Float?
    var minTime: String?
    var maxTime: String?
    var vendorPicture: String?
    var vendorLogo: String?
    var favourite: Bool?
    var finished: Int?
    var category: String?
    
    //empty constructor
    override init()
    {
        
    }
    
    //construct with @name, @email and @telephone parameters
    init(id: Int, name: String, rating: Float, latitude: Double, longitude: Double, price: Float, minTime: String, maxTime: String, vendorPicture: String, vendorLogo: String, favourite: Bool, finished: Int, category: String) {
        
        self.id = id
        self.name = name
        self.rating = rating
        self.latitude = latitude
        self.longitude = longitude
        self.price = price
        self.minTime = minTime
        self.maxTime = maxTime
        self.vendorPicture = vendorPicture
        self.vendorLogo = vendorLogo
        self.favourite = favourite
        self.finished = finished
        self.category = category
    }
    
    func setDistance(location: CLLocation) {
        self.distance = Int(round(location.distance(from: CLLocation(latitude: self.latitude!, longitude: self.longitude!))))
    }
    
    //prints object's current state
    override var description: String {
        return "ID: \(String(describing: id)), Name: \(String(describing: name)), Rating: \(String(describing: rating)), Distance: \(String(describing: distance)), Latitude: \(String(describing: latitude)), Longitude: \(String(describing: longitude)), Price: \(String(describing: price)), Time: \(String(describing: minTime))-\(String(describing: maxTime)), VendorPicture: \(String(describing: vendorPicture)), VendorLogo: \(String(describing: vendorLogo)), Favourite: \(String(describing: favourite)), Finished: \(String(describing: finished)), Category: \(String(describing: category))"
    }
}
