//
//  ReceiptsModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 12/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

// Protocol used for delegating the receipt responses to the class that implements it
protocol ReceiptsModelProtocol: class {
    func receiptsReceived(_ receipts: [[String:Any]])
    func redeemStatus(_ result: [String:Any], row: Int)
}

// The class used for the receipts requests
class ReceiptsModel: NSObject, URLSessionDataDelegate {
    weak var delegate: ReceiptsModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // The request for receipts
    func requestReceipts() {
        if let userId = UserDefaults.standard.value(forKey: "userId") {
            self.data = NSMutableData()
            let url: URL = URL(string: "\(Utils.serverAddress)/services/receipts.php")!
            let session = URLSession.shared
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            let paramString = "userId=\(userId)"
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
                        self.delegate.receiptsReceived(parsedData)
                    })
                } catch let error as NSError {
                    print(error)
                }
            })
            task.resume()
        }
    }
    
    // The request for redeeming a receipt
    func redeem(receiptId: Int, row: Int) {
        self.data = NSMutableData()
        let url: URL = URL(string: "\(Utils.serverAddress)/services/redeem_offer.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let paramString = "receiptId=\(receiptId)"
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
                    self.delegate.redeemStatus(parsedData, row: row)
                })
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
}
