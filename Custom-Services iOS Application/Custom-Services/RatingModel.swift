//
//  RatingModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 11/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

// Protocol used for delegating the rating responses to the class that implements it
protocol LocationRatingModelProtocol: class {
    func ratingResponse(_ result: NSString)
}

// The class used for the rating requests
class RatingModel: NSObject, URLSessionDataDelegate {
    weak var delegate: LocationRatingModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // The request for sending a rating score
    func sendRating(locationId: Int, rating: Int) {
        if let userId = UserDefaults.standard.value(forKey: "userId") {
            self.data = NSMutableData()
            let url: URL = URL(string: "\(Utils.serverAddress)/services/location_rating.php")!
            let session = URLSession.shared
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            let paramString = "userId=\(userId)&locationId=\(locationId)&rating=\(rating)"
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error")
                    return
                }
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.delegate.ratingResponse(dataString!)
                })
            })
            task.resume()
        }
    }
}
