//
//  ReceiptModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 12/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

class ReceiptModel: NSObject, NSCoding {
    
    //properties
    var id: Int?
    var offerId: Int?
    var name: String?
    var timeInterval: String?
    var discount: Float?
    var offerLogo: String?
    var redeemed: Int?
    
    //empty constructor
    override init()
    {
        
    }
    
    //construct with @name, @email and @telephone parameters
    init(id: Int, offerId: Int, name: String, timeInterval: String, discount: Float, offerLogo: String, redeemed: Int) {
        
        self.id = id
        self.offerId = offerId
        self.name = name
        self.timeInterval = timeInterval
        self.discount = discount
        self.offerLogo = offerLogo
        self.redeemed = redeemed
    }
    
    required init(coder decoder: NSCoder) {
        self.id = decoder.decodeObject(forKey: "id") as? Int
        self.offerId = decoder.decodeObject(forKey: "offerId") as? Int
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.timeInterval = decoder.decodeObject(forKey: "timeInterval") as? String ?? ""
        self.discount = decoder.decodeObject(forKey: "discount") as? Float
        self.offerLogo = decoder.decodeObject(forKey: "offerLogo") as? String ?? ""
        self.redeemed = decoder.decodeObject(forKey: "redeemed") as? Int
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(offerId, forKey: "offerId")
        coder.encode(name, forKey: "name")
        coder.encode(timeInterval, forKey: "timeInterval")
        coder.encode(discount, forKey: "discount")
        coder.encode(offerLogo, forKey: "offerLogo")
        coder.encode(redeemed, forKey: "redeemed")
    }
    
    //prints object's current state
    override var description: String {
        return "ID: \(String(describing: id)), OfferId: \(String(describing: offerId)), Name: \(String(describing: name)), TimeInterval: \(String(describing: timeInterval)), Discount: \(String(describing: discount)), OfferLogo: \(String(describing: offerLogo)), Redeemed: \(String(describing: redeemed))"
    }
}
