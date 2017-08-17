//
//  RatingModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 11/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

protocol LocationRatingModelProtocol: class {
    func ratingResponse(_ result: NSString)
}

class RatingModel: NSObject, URLSessionDataDelegate {
    
    //properties
    weak var delegate: LocationRatingModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // Server request function for validating log in credentials
    func sendRating(locationId: Int, rating: Int) {
        
        if let userId = UserDefaults.standard.value(forKey: "userId") {
            
            self.data = NSMutableData()
            
            // Setting up the server session with the URL and the request
            let url: URL = URL(string: "https://custom-services.co.uk/services/location_rating.php")!
            let session = URLSession.shared
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            
            // Request parameters
            let paramString = "userId=\(userId)&locationId=\(locationId)&rating=\(rating)"
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                
                // Check for request errors
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error")
                    return
                }
                
                // Calling the success handler asynchroniously
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.delegate.ratingResponse(dataString!)
                })
            })
            task.resume()
        }
    }
}
