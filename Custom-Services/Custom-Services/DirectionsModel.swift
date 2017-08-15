//
//  DirectionsModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 14/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation
import CoreLocation

protocol DirectionsModelProtocol: class {
    func directionsReceived(_ directions: [[String:AnyObject]], startingLocation: CLLocation)
}

class DirectionsModel: NSObject, URLSessionDataDelegate {
    
    //properties
    weak var delegate: DirectionsModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // Server request function for validating log in credentials
    func requestOffers(currLatitude: Double, currLongitude: Double, destLatitude: Double, destLongitude: Double) {
        
        self.data = NSMutableData()
        
        // Setting up the server session with the URL and the request
        let url: URL = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(currLatitude),\(currLongitude)&destination=\(destLatitude),\(destLongitude)&mode=walking&key=AIzaSyDq0NHQJFAFPFGrQzEiizNliDANjt3pe7k")!
        print(url.absoluteString)
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            // Check for request errors
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            
            do {
                // Sending the received JSON
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
                DispatchQueue.main.async(execute: { () -> Void in
                    // Calling the success handler asynchroniously
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
