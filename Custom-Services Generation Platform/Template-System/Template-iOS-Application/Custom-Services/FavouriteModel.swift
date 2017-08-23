//
//  FavouriteModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 11/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

// Protocol used for delegating the favourite offers responses to the class that implements it
protocol FavouriteModelProtocol: class {
    func favouriteSelected(_ result: NSString, tag: Int)
}

// The class used for the favourites requests
class FavouriteModel: NSObject, URLSessionDataDelegate {
    weak var delegate: FavouriteModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // The request for setting a favourite corelation
    func sendFavourite(locationId: Int, favourite: Int, tag: Int) {
        if let userId = UserDefaults.standard.value(forKey: "userId") {
            self.data = NSMutableData()
            let url: URL = URL(string: "\(Utils.serverAddress)/services/update_favourite.php")!
            let session = URLSession.shared
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            let paramString = "userId=\(userId)&locationId=\(locationId)&favourite=\(favourite)"
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error")
                    return
                }
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.delegate.favouriteSelected(dataString!, tag: tag)
                })
            })
            task.resume()
        }
    }
}
