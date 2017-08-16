//
//  PointModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 15/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PointModel: NSObject, NSCoding {
    
    var latitude: Double?
    var longitude: Double?
    var radius: CLLocationDistance?
    var id: Int?
    var name: String?

    //empty constructor
    override init() {
        
    }
    
    init(id: Int, name: String, latitude: Double, longitude: Double, radius: CLLocationDistance) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.id = id
        self.name = name
    }
    
    required init(coder decoder: NSCoder) {
        self.latitude = decoder.decodeObject(forKey: "latitude") as? Double
        self.longitude = decoder.decodeObject(forKey: "longitude") as? Double
        self.id = decoder.decodeObject(forKey: "id") as? Int
        self.radius = decoder.decodeObject(forKey: "radius") as? Double
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(name, forKey: "name")
        coder.encode(radius, forKey: "radius")
        coder.encode(latitude, forKey: "latitude")
        coder.encode(longitude, forKey: "longitude")
    }
    
}
