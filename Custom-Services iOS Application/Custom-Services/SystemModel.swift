//
//  SystemModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 06/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

// Protocol used for delegating the system responses to the class that implements it
protocol SystemModelProtocol: class {
    func systemDataReceived(_ systemData: [String:Any])
    func categoriesReceived(_ systemData: [[String:Any]])
}

// The class used for the system requests
class SystemModel: NSObject, URLSessionDataDelegate {
    weak var delegate: SystemModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // The request for system customisation options
    func requestSystemData() {
        self.data = NSMutableData()
        let url: URL = URL(string: "\(Utils.serverAddress)/services/system.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                DispatchQueue.main.async(execute: { () -> Void in
                    self.delegate.systemDataReceived(parsedData)
                })
                
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
    
    // The request for the possible product or service categories
    func requestCategories() {
        self.data = NSMutableData()
        let url: URL = URL(string: "\(Utils.serverAddress)/services/categories.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String:Any]]
                DispatchQueue.main.async(execute: { () -> Void in
                    self.delegate.categoriesReceived(parsedData)
                })
                
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
}
