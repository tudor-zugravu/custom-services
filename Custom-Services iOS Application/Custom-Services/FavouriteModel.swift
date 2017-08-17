//
//  FavouriteModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 11/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

protocol FavouriteModelProtocol: class {
    func favouriteSelected(_ result: NSString, tag: Int)
}

class FavouriteModel: NSObject, URLSessionDataDelegate {
    
    //properties
    weak var delegate: FavouriteModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // Server request function for validating log in credentials
    func sendFavourite(locationId: Int, favourite: Int, tag: Int) {
        
        if let userId = UserDefaults.standard.value(forKey: "userId") {
            
            self.data = NSMutableData()
            
            // Setting up the server session with the URL and the request
            let url: URL = URL(string: "https://custom-services.co.uk/services/update_favourite.php")!
            let session = URLSession.shared
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            
            // Request parameters
            let paramString = "userId=\(userId)&locationId=\(locationId)&favourite=\(favourite)"
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
                    self.delegate.favouriteSelected(dataString!, tag: tag)
                })
            })
            task.resume()
        }
    }
}
