//
//  VendorModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 01/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import CoreLocation


// The class used for the structure of Offer objects
class OfferModel: NSObject, NSCoding {
    var id: Int?
    var locationId: Int?
    var name: String?
    var address: String?
    var about: String?
    var rating: Float?
    var distance: Int?
    var latitude: Double?
    var longitude: Double?
    var discount: Float?
    var minTime: String?
    var maxTime: String?
    var offerImage: String?
    var offerLogo: String?
    var favourite: Bool?
    var quantity: Int?
    var category: String?
    var discountRange: String?
    var appointmentDuration: Int?

    override init() {
        self.distance = 0
    }

    init(id: Int, locationId: Int, name: String, address: String, about: String, rating: Float, latitude: Double, longitude: Double, discount: Float, minTime: String, maxTime: String, offerImage: String, offerLogo: String, favourite: Bool, quantity: Int, appointmentDuration: Int) {
        
        self.id = id
        self.locationId = locationId
        self.name = name
        self.address = address
        self.about = about
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
        self.appointmentDuration = appointmentDuration
    }
    
    required init(coder decoder: NSCoder) {
        self.id = decoder.decodeObject(forKey: "id") as? Int
        self.locationId = decoder.decodeObject(forKey: "locationId") as? Int
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.address = decoder.decodeObject(forKey: "address") as? String ?? ""
        self.about = decoder.decodeObject(forKey: "about") as? String ?? ""
        self.rating = decoder.decodeObject(forKey: "rating") as? Float
        self.distance = decoder.decodeObject(forKey: "distance") as? Int
        self.latitude = decoder.decodeObject(forKey: "latitude") as? Double
        self.longitude = decoder.decodeObject(forKey: "longitude") as? Double
        self.discount = decoder.decodeObject(forKey: "discount") as? Float
        self.minTime = decoder.decodeObject(forKey: "minTime") as? String ?? ""
        self.maxTime = decoder.decodeObject(forKey: "maxTime") as? String ?? ""
        self.offerImage = decoder.decodeObject(forKey: "offerImage") as? String ?? ""
        self.offerLogo = decoder.decodeObject(forKey: "offerLogo") as? String ?? ""
        self.favourite = decoder.decodeObject(forKey: "favourite") as? Bool
        self.quantity = decoder.decodeObject(forKey: "quantity") as? Int
        self.category = decoder.decodeObject(forKey: "category") as? String ?? ""
        self.appointmentDuration = decoder.decodeObject(forKey: "appointmentDuration") as? Int
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(locationId, forKey: "locationId")
        coder.encode(name, forKey: "name")
        coder.encode(address, forKey: "address")
        coder.encode(about, forKey: "about")
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
        coder.encode(appointmentDuration, forKey: "appointmentDuration")
    }
    
    // Calculates the distance between the current position and the input location
    func setDistance(location: CLLocation) {
        self.distance = Int(round(location.distance(from: CLLocation(latitude: self.latitude!, longitude: self.longitude!))))
        if self.distance == nil {
            self.distance = 0
        }
    }
    
    override var description: String {
        return "ID: \(String(describing: id)), LocationId: \(String(describing: locationId)), Name: \(String(describing: name)), Address: \(String(describing: address)), About: \(String(describing: about)), Rating: \(String(describing: rating)), Distance: \(String(describing: distance)), Latitude: \(String(describing: latitude)), Longitude: \(String(describing: longitude)), Discount: \(String(describing: discount)), Time: \(String(describing: minTime))-\(String(describing: maxTime)), OfferImage: \(String(describing: offerImage)), OfferLogo: \(String(describing: offerLogo)), Favourite: \(String(describing: favourite)), Quantity: \(String(describing: quantity)), AppointmentDuration: \(String(describing: appointmentDuration)), Category: \(String(describing: category))"
    }
}
