//
//  ReceiptsModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 12/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

protocol ReceiptsModelProtocol: class {
    func receiptsReceived(_ receipts: [[String:Any]])
    func redeemStatus(_ result: [String:Any], row: Int)
}

class ReceiptsModel: NSObject, URLSessionDataDelegate {
    
    //properties
    weak var delegate: ReceiptsModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // Server request function for validating log in credentials
    func requestReceipts() {
        
        if let userId = UserDefaults.standard.value(forKey: "userId") {
            
            self.data = NSMutableData()
            
            // Setting up the server session with the URL and the request
            let url: URL = URL(string: "http://46.101.29.197/services/receipts.php")!
            let session = URLSession.shared
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            
            // Request parameters
            let paramString = "userId=\(userId)"
            
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                
                // Check for request errors
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error")
                    return
                }
                
                do {
                    // Sending the received JSON
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String:Any]]
                    DispatchQueue.main.async(execute: { () -> Void in
                        // Calling the success handler asynchroniously
                        self.delegate.receiptsReceived(parsedData)
                    })
                    
                } catch let error as NSError {
                    print(error)
                }
            })
            task.resume()
        }
    }
    
    // Server request function for validating log in credentials
    func redeem(receiptId: Int, row: Int) {
        
        self.data = NSMutableData()
        
        // Setting up the server session with the URL and the request
        let url: URL = URL(string: "http://46.101.29.197/services/redeem_offer.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        // Request parameters
        let paramString = "receiptId=\(receiptId)"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            // Check for request errors
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            
            do {
                // Sending the received JSON
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    // Calling the success handler asynchroniously
                    self.delegate.redeemStatus(parsedData, row: row)
                })
                
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
}
