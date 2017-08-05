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
            return time % 4 == 0 ? "0\(time / 4 + 8):0\((time % 4) * 15)" : "0\(time / 4 + 8):\((time % 4) * 15)"
        } else {
            return time % 4 == 0 ? "\(time / 4 + 8):0\((time % 4) * 15)" : "\(time / 4 + 8):\((time % 4) * 15)"
        }
    }
    
    func getTimeInt(time: String) -> Int {
        let timeComponents = time.components(separatedBy: ":")
        return (Int(timeComponents[0])! - 8) * 4 + Int(timeComponents[1])! / 15
    }
    
    func filterVendors(vendors: [VendorModel], distance: Int, minTime: String, maxTime: String, sortBy: Int, onlyAvailableOffers: Bool, allCategories: Bool, allowedCategories: [String]) -> [VendorModel] {
        
        return vendors.filter({ (vendor) -> Bool in
            if vendor.distance > distance * 1000 {
                return false
            }
            if ((strcmp(vendor.minTime!, maxTime) > 0) || (strcmp(vendor.maxTime!, minTime) <= 0)) {
                return false
            }
            if onlyAvailableOffers && vendor.finished! > 0 {
                return false
            }
            if !allCategories && !allowedCategories.contains(vendor.category!) {
                return false
            }
            return true
        }).sorted(by: { (vendor1, vendor2) -> Bool in
            switch sortBy {
            case 0:
                if vendor1.distance < vendor2.distance {
                    return true
                }
                break
            case 1:
                if vendor1.rating! - vendor2.rating! > 0 {
                    return true
                }
                break
            default:
                if vendor1.price! - vendor2.price! < 0 {
                    return true
                }
            }
            return false
        })
    }
}
