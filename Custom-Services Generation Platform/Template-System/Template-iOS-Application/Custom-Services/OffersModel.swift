//
//  OffersModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 06/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

// Protocol used for delegating the offers responses to the class that implements it
protocol OffersModelProtocol: class {
    func offersReceived(_ offers: [[String:Any]])
    func favouriteSelected(_ result: NSString, tag: Int)
}

// The class used for the offer requests
class OffersModel: NSObject, URLSessionDataDelegate {
    weak var delegate: OffersModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // The request for offers
    func requestOffers(hasCategories: Bool) {
        if let userId = UserDefaults.standard.value(forKey: "userId") {
            self.data = NSMutableData()
            let url: URL = URL(string: "\(Utils.serverAddress)/services/offers.php")!
            let session = URLSession.shared
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            let paramString = "userId=\(userId)&hasCategories=\(hasCategories)"
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error")
                    return
                }
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String:Any]]
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.delegate.offersReceived(parsedData)
                    })
                } catch let error as NSError {
                    print(error)
                }
            })
            task.resume()
        }
    }
    
    // The request for saving a favourite corelation
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
