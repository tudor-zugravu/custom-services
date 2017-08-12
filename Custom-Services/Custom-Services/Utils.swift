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
    
    func getMinutes(time: String) -> Int {
        let timeComponents = time.components(separatedBy: ":")
        return Int(timeComponents[0])! * 60 + Int(timeComponents[1])!
    }
    
    func getHour(time: Int) -> String {
        if time < 600 {
            return time % 60 < 10 ? "0\(time / 60):0\(time % 60)" : "0\(time / 60):\(time % 60)"
        } else {
            return time % 60 < 10 ? "\(time / 60):0\(time % 60)" : "\(time / 60):\(time % 60)"
        }
    }
    
    func getIndex(startingTime: String, duration: Int, time: String) -> Int {
        let timeComponents = time.components(separatedBy: "-")
        return (getMinutes(time: timeComponents[0]) - getMinutes(time: startingTime)) / duration
    }
    
    func getTimeIntervals(startingTime: String, endingTime: String, duration: Int, appointments: [Int]) -> [String] {
        let start = getMinutes(time: startingTime)
        let end = getMinutes(time: endingTime)
        let intervals = (end - start) / duration
        var timeIntervals: [String] = []
        
        for i in 0..<intervals {
            if !appointments.contains(i) {
                timeIntervals.append("\(getHour(time: start + i * duration))-\(getHour(time: start + (i+1) * duration))")
            }
        }
        
        return timeIntervals
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
        })
    }
    
    func sortOffers(offers: [OfferModel], sortBy: Int) -> [OfferModel] {
        return offers.sorted(by: { (offer1, offer2) -> Bool in
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
                var offer1Discount: Float = 0
                var offer2Discount: Float = 0
                if UserDefaults.standard.value(forKey: "type") as! String == "location" {
                    if offer1.discountRange != nil && offer1.discountRange != "" {
                        let discounts = offer1.discountRange?.components(separatedBy: "-")
                        offer1Discount = Float(discounts![1])!
                    } else {
                        offer1Discount = offer1.discount!
                    }
                    if offer2.discountRange != nil && offer2.discountRange != "" {
                        let discounts = offer2.discountRange?.components(separatedBy: "-")
                        offer2Discount = Float(discounts![1])!
                    } else {
                        offer2Discount = offer2.discount!
                    }
                    if offer1Discount - offer2Discount > 0 {
                        return true
                    }
                    if fabs(offer1Discount - offer2Discount) < 0.000001 && offer1.distance! < offer2.distance! {
                        return true
                    }
                } else {
                    if offer1.discountRange != nil && offer1.discountRange != "" {
                        let discounts = offer1.discountRange?.components(separatedBy: "-")
                        offer1Discount = Float(discounts![0])!
                    } else {
                        offer1Discount = offer1.discount!
                    }
                    if offer2.discountRange != nil && offer2.discountRange != "" {
                        let discounts = offer2.discountRange?.components(separatedBy: "-")
                        offer2Discount = Float(discounts![0])!
                    } else {
                        offer2Discount = offer2.discount!
                    }
                    if offer2Discount - offer1Discount > 0 {
                        return true
                    }
                    if fabs(offer1Discount - offer2Discount) < 0.000001 && offer2.distance! < offer1.distance! {
                        return true
                    }
                }
            }
            return false
        })
    }
    
    func removeDuplicateLocations(offers: [OfferModel], onlyAvailableOffers: Bool) -> [OfferModel] {
        
        guard let firstOffer = offers.first else {
            return [] // Empty array
        }
        
        var currentOffer = firstOffer
        var numberOfFirsts = 0
        
        if onlyAvailableOffers && UserDefaults.standard.value(forKey: "type") as! String != "location" {
            while currentOffer.quantity! == 0 {
                numberOfFirsts += 1
                if numberOfFirsts == offers.count {
                    return []
                } else {
                    currentOffer = offers[numberOfFirsts]
                }
            }
        }
        var uniqueOffers = [currentOffer] // Keep first element
        
        for offer in offers.dropFirst(numberOfFirsts + 1) {
            if UserDefaults.standard.value(forKey: "type") as! String != "location" && (onlyAvailableOffers ? offer.quantity! > 0 : true) {
                if offer.locationId == currentOffer.locationId && offer.id != currentOffer.id && offer.discount != currentOffer.discount {
                    currentOffer.quantity! += offer.quantity!
                    if currentOffer.discountRange != nil && currentOffer.discountRange != "" {
                        let discounts = currentOffer.discountRange?.components(separatedBy: "-")
                        if Float(discounts![0])! - offer.discount! > 0 {
                            if UserDefaults.standard.value(forKey: "type") as! String == "location" {
                                currentOffer.discountRange = "\(Int(offer.discount!)) - \(discounts![1])"
                            } else {
                                currentOffer.discountRange = "\(offer.discount!) - \(discounts![1])"
                            }
                        } else if Float(discounts![1])! - offer.discount! < 0 {
                            if UserDefaults.standard.value(forKey: "type") as! String == "location" {
                                currentOffer.discountRange = "\(discounts![0]) - \(Int(offer.discount!))"
                            } else {
                                currentOffer.discountRange = "\(discounts![0]) - \(offer.discount!)"
                            }
                        }
                    } else {
                        if UserDefaults.standard.value(forKey: "type") as! String == "location" {
                            currentOffer.discountRange = currentOffer.discount! > offer.discount! ? "\(Int(offer.discount!)) - \(Int(currentOffer.discount!))" : "\(Int(currentOffer.discount!)) - \(Int(offer.discount!))"
                        } else {
                            currentOffer.discountRange = currentOffer.discount! > offer.discount! ? "\(offer.discount!) - \(currentOffer.discount!)" : "\(currentOffer.discount!) - \(offer.discount!)"
                        }
                    }
                } else {
                    currentOffer = offer
                    uniqueOffers.append(currentOffer) // Found a different element
                }
            } else if UserDefaults.standard.value(forKey: "type") as! String == "location" {
                if offer.locationId == currentOffer.locationId && offer.id != currentOffer.id && offer.discount != currentOffer.discount {
                    if currentOffer.discountRange != nil && currentOffer.discountRange != "" {
                        let discounts = currentOffer.discountRange?.components(separatedBy: "-")
                        if Float(discounts![0])! - offer.discount! > 0 {
                            if UserDefaults.standard.value(forKey: "type") as! String == "location" {
                                currentOffer.discountRange = "\(Int(offer.discount!)) - \(discounts![1])"
                            } else {
                                currentOffer.discountRange = "\(offer.discount!) - \(discounts![1])"
                            }
                        } else if Float(discounts![1])! - offer.discount! < 0 {
                            if UserDefaults.standard.value(forKey: "type") as! String == "location" {
                                currentOffer.discountRange = "\(discounts![0]) - \(Int(offer.discount!))"
                            } else {
                                currentOffer.discountRange = "\(discounts![0]) - \(offer.discount!)"
                            }
                        }
                    } else {
                        if UserDefaults.standard.value(forKey: "type") as! String == "location" {
                            currentOffer.discountRange = currentOffer.discount! > offer.discount! ? "\(Int(offer.discount!)) - \(Int(currentOffer.discount!))" : "\(Int(currentOffer.discount!)) - \(Int(offer.discount!))"
                        } else {
                            currentOffer.discountRange = currentOffer.discount! > offer.discount! ? "\(offer.discount!) - \(currentOffer.discount!)" : "\(currentOffer.discount!) - \(offer.discount!)"
                        }
                    }
                } else {
                    currentOffer = offer
                    uniqueOffers.append(currentOffer) // Found a different element
                }
            }
        }
        return uniqueOffers
    }
    
    // COPIED
    // Function that returns the path of the images
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // COPIED
    func isValidEmailFormat(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    func signOut() {
        // Delete profile picture
        if UserDefaults.standard.value(forKey: "profilePicture") as! String != "" {
            do {
                let fileManager = FileManager.default
                let fileName = getDocumentsDirectory().appendingPathComponent("\(UserDefaults.standard.value(forKey: "profilePicture")!)").path
                
                if fileManager.fileExists(atPath: fileName) {
                    try fileManager.removeItem(atPath: fileName)
                } else {
                    print("File does not exist")
                }
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
        }
        
        // Delete stored user data
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey:"userId")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "profilePicture")
        UserDefaults.standard.removeObject(forKey: "credit")
    }
}
