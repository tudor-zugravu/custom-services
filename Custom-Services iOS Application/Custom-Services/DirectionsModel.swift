//
//  DirectionsModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 14/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation
import CoreLocation

// Protocol used for delegating the navigation responses to the class that implements it
protocol DirectionsModelProtocol: class {
    func directionsReceived(_ directions: [[String:AnyObject]], startingLocation: CLLocation)
}

// The class used for the navigation requests
class DirectionsModel: NSObject, URLSessionDataDelegate {
    weak var delegate: DirectionsModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // The request for navigation directions
    func requestOffers(currLatitude: Double, currLongitude: Double, destLatitude: Double, destLongitude: Double) {
        self.data = NSMutableData()
        let url: URL = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(currLatitude),\(currLongitude)&destination=\(destLatitude),\(destLongitude)&mode=walking&key=\(Utils.googleAPIKey)")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
                DispatchQueue.main.async(execute: { () -> Void in
                    if let routes = parsedData["routes"] as? [[String:AnyObject]] {
                        if let legs = routes[0]["legs"] as? [[String:AnyObject]] {
                            if let steps = legs[0]["steps"] as? [[String:AnyObject]] {
                                self.delegate.directionsReceived(steps, startingLocation: CLLocation(latitude: currLatitude, longitude: currLongitude))
                            } else {
                                print("no steps")
                            }
                        } else {
                            print("no legs")
                        }
                    } else {
                        print("no routes")
                    }
                })
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
}
