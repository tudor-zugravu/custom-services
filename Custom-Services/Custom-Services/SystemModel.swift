//
//  SystemModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 06/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

protocol SystemModelProtocol: class {
    func systemDataReceived(_ systemData: [String:Any])
    func categoriesReceived(_ systemData: [[String:Any]])
}

class SystemModel: NSObject, URLSessionDataDelegate {
    
    //properties
    weak var delegate: SystemModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // Server request function for validating log in credentials
    func requestSystemData() {
        
        self.data = NSMutableData()
        
        // Setting up the server session with the URL and the request
        let url: URL = URL(string: "http://46.101.29.197/services/system.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
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
                    self.delegate.systemDataReceived(parsedData)
                })
                
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
    
    // Server request function for validating log in credentials
    func requestCategories() {
        
        self.data = NSMutableData()
        
        // Setting up the server session with the URL and the request
        let url: URL = URL(string: "http://46.101.29.197/services/categories.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
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
                    self.delegate.categoriesReceived(parsedData)
                })
                
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
}
