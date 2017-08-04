//
//  Utils.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 03/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

private let _instance = Utils()

class Utils: NSObject {
    
    fileprivate override init() {
        
    }
    
    class var instance: Utils {
        return _instance
    }

    func getTime(time: Int) -> String {
        if time < 8 {
            if time % 4 == 0 {
                return "0\(time / 4 + 8):0\((time % 4) * 15)"
            } else {
                return "0\(time / 4 + 8):\((time % 4) * 15)"
            }
        } else {
            if time % 4 == 0 {
                return "\(time / 4 + 8):0\((time % 4) * 15)"
            } else {
                return "\(time / 4 + 8):\((time % 4) * 15)"
            }
        }
    }
    
    //properties
//    var name: String?
//    var rating: Float?
//    var distance: Int = 0
//    var latitude: Double?
//    var longitude: Double?
//    var price: Float?
//    var minTime: String?
//    var maxTime: String?
//    var vendorPicture: String?
//    var vendorLogo: String?
//    var favourite: Bool?
//    var finished: Int?
    
    func filterVendors(vendors: [VendorModel], distance: Int, minTime: String, maxTime: String, sortBy: Int, onlyAvailableOffers: Bool, allCategories: Bool, allowedCategories: [String]) -> [VendorModel] {
        
//        print("\(distance) \(minTime) \(maxTime) \(sortBy) \(onlyAvailableOffers) \(allCategories) \(allowedCategories)")
        
        return vendors.filter({ (vendor) -> Bool in
            
//            print(vendor.description)
            
            if vendor.distance > distance * 1000 {
                return false
            }
            if ((strcmp(vendor.minTime!, maxTime) > 0) || (strcmp(vendor.maxTime!, minTime) <= 0)) {
                print("NO \(vendor.minTime!)-\(vendor.maxTime!) \(minTime)-\(maxTime)")
                return false
            }
            if onlyAvailableOffers && vendor.finished! > 0 {
                return false
            }
            
            print("YES \(vendor.minTime!)-\(vendor.maxTime!) \(minTime)-\(maxTime)")
            return true
        })
    }
}
