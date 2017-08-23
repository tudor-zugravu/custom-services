//
//  CheckoutModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 12/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

// Protocol used for delegating the purchasing responses to the class that implements it
protocol CheckoutModelProtocol: class {
    func productCheckoutResponse(_ result: [String:Any])
    func serviceCheckoutResponse(_ result: [String:Any])
}

// The class used for the purchasing requests
class CheckoutModel: NSObject, URLSessionDataDelegate {
    weak var delegate: CheckoutModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // The request for purchasing a product offer
    func productCheckout(offerId: Int) {
        if let userId = UserDefaults.standard.value(forKey: "userId") {
            self.data = NSMutableData()
            let url: URL = URL(string: "\(Utils.serverAddress)/services/product_checkout.php")!
            let session = URLSession.shared
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            let paramString = "userId=\(userId)&offerId=\(offerId)"
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
                        self.delegate.productCheckoutResponse(parsedData)
                    })
                } catch let error as NSError {
                    print(error)
                }
            })
            task.resume()
        }
    }
    
    // The request for purchasing a service offer
    func serviceCheckout(offerId: Int, appointment: Int) {
        if let userId = UserDefaults.standard.value(forKey: "userId") {
            self.data = NSMutableData()
            let url: URL = URL(string: "\(Utils.serverAddress)/services/service_checkout.php")!
            let session = URLSession.shared
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            let paramString = "userId=\(userId)&offerId=\(offerId)&appointment=\(appointment)"
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
                        self.delegate.serviceCheckoutResponse(parsedData)
                    })
                } catch let error as NSError {
                    print(error)
                }
            })
            task.resume()
        }
    }
}
