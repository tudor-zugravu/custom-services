//
//  VendorModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 01/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import CoreLocation

class OfferModel: NSObject, NSCoding {

    //properties
    var id: Int?
    var name: String?
    var rating: Float?
    var distance: Int?
    var latitude: Double?
    var longitude: Double?
    var discount: Int?
    var minTime: String?
    var maxTime: String?
    var offerImage: String?
    var offerLogo: String?
    var favourite: Bool?
    var quantity: Int?
    var category: String?
    
    //empty constructor
    override init()
    {
        
    }
    
    //construct with @name, @email and @telephone parameters
    init(id: Int, name: String, rating: Float, latitude: Double, longitude: Double, discount: Int, minTime: String, maxTime: String, offerImage: String, offerLogo: String, favourite: Bool, quantity: Int, category: String) {
        
        self.id = id
        self.name = name
        self.rating = rating
        self.distance = 0
        self.latitude = latitude
        self.longitude = longitude
        self.discount = discount
        self.minTime = minTime
        self.maxTime = maxTime
        self.offerImage = offerImage
        self.offerLogo = offerLogo
        self.favourite = favourite
        self.quantity = quantity
        self.category = category
    }
    
    required init(coder decoder: NSCoder) {
        self.id = decoder.decodeObject(forKey: "id") as? Int
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.rating = decoder.decodeObject(forKey: "rating") as? Float
        self.distance = decoder.decodeObject(forKey: "distance") as? Int
        self.latitude = decoder.decodeObject(forKey: "latitude") as? Double
        self.longitude = decoder.decodeObject(forKey: "longitude") as? Double
        self.discount = decoder.decodeObject(forKey: "discount") as? Int
        self.minTime = decoder.decodeObject(forKey: "minTime") as? String ?? ""
        self.maxTime = decoder.decodeObject(forKey: "maxTime") as? String ?? ""
        self.offerImage = decoder.decodeObject(forKey: "offerImage") as? String ?? ""
        self.offerLogo = decoder.decodeObject(forKey: "offerLogo") as? String ?? ""
        self.favourite = decoder.decodeObject(forKey: "favourite") as? Bool
        self.quantity = decoder.decodeObject(forKey: "quantity") as? Int
        self.category = decoder.decodeObject(forKey: "category") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(name, forKey: "name")
        coder.encode(rating, forKey: "rating")
        coder.encode(distance, forKey: "distance")
        coder.encode(latitude, forKey: "latitude")
        coder.encode(longitude, forKey: "longitude")
        coder.encode(discount, forKey: "discount")
        coder.encode(minTime, forKey: "minTime")
        coder.encode(maxTime, forKey: "maxTime")
        coder.encode(offerImage, forKey: "offerImage")
        coder.encode(offerLogo, forKey: "offerLogo")
        coder.encode(favourite, forKey: "favourite")
        coder.encode(quantity, forKey: "quantity")
        coder.encode(category, forKey: "category")
    }
    
    func setDistance(location: CLLocation) {
        self.distance = Int(round(location.distance(from: CLLocation(latitude: self.latitude!, longitude: self.longitude!))))
    }
    
    //prints object's current state
    override var description: String {
        return "ID: \(String(describing: id)), Name: \(String(describing: name)), Rating: \(String(describing: rating)), Distance: \(String(describing: distance)), Latitude: \(String(describing: latitude)), Longitude: \(String(describing: longitude)), Discount: \(String(describing: discount)), Time: \(String(describing: minTime))-\(String(describing: maxTime)), OfferImage: \(String(describing: offerImage)), OfferLogo: \(String(describing: offerLogo)), Favourite: \(String(describing: favourite)), Quantity: \(String(describing: quantity)), Category: \(String(describing: category))"
    }
}
