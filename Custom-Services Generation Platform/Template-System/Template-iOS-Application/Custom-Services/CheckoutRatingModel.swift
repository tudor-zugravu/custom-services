//
//  CheckoutRatingModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 12/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

// Protocol used for delegating the rating of purchased products responses to the class that implements it
protocol CheckoutRatingModelProtocol: class {
    func ratingResponse(_ result: [String:Any])
}

// The class used for the rating of purchases requests
class CheckoutRatingModel: NSObject, URLSessionDataDelegate {
    weak var delegate: CheckoutRatingModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // The request for sending purchases ratings
    func sendRating(receiptId: Int, locationId: Int, rating: Int) {
        self.data = NSMutableData()
        let url: URL = URL(string: "\(Utils.serverAddress)/services/rating.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let paramString = "receiptId=\(receiptId)&locationId=\(locationId)&rating=\(rating)"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                DispatchQueue.main.async(execute: { () -> Void in
                    self.delegate.ratingResponse(parsedData)
                })
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
}
