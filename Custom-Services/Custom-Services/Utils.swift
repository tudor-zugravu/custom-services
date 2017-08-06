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
    
    func trimSeconds(time: String) -> String {
        let timeComponents = time.components(separatedBy: ":")
        return "\(timeComponents[0]):\(timeComponents[1])"
    }
    
    func filterOffers(offers: [OfferModel], distance: Int, minTime: String, maxTime: String, sortBy: Int, onlyAvailableOffers: Bool, allCategories: Bool, allowedCategories: [String]) -> [OfferModel] {
        
        return offers.filter({ (offer) -> Bool in
            if offer.distance! > distance * 1000 {
                return false
            }
            if ((strcmp(offer.minTime!, maxTime) > 0) || (strcmp(offer.maxTime!, minTime) <= 0)) {
                return false
            }
            if onlyAvailableOffers && offer.quantity! == 0 {
                return false
            }
            if !allCategories && !allowedCategories.contains(offer.category!) {
                return false
            }
            return true
        }).sorted(by: { (offer1, offer2) -> Bool in
            switch sortBy {
            case 0:
                if offer1.distance! < offer2.distance! {
                    return true
                }
                break
            case 1:
                if offer1.rating! - offer2.rating! > 0 {
                    return true
                }
                if fabs(offer1.rating! - offer2.rating!) < 0.000001 && offer1.distance! < offer2.distance! {
                    return true
                }
                break
            default:
                if offer1.discount! - offer2.discount! > 0 {
                    return true
                }
                if offer1.rating! == offer2.rating! && offer1.distance! < offer2.distance! {
                    return true
                }
            }
            return false
        })
    }
    
    // COPIED
    // Function that returns the path of the images
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
