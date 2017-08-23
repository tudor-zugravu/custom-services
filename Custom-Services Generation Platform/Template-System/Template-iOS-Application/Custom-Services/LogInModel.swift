//
//  LogInModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 07/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

protocol LogInModelProtocol: class {
    func responseReceived(_ response: [String:Any])
}

class LogInModel: NSObject, URLSessionDataDelegate {
    
    //properties
    weak var delegate: LogInModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // Server request function for validating log in credentials
    func checkCredentials(email: String, password: String) {
        
        self.data = NSMutableData()
        
        // Setting up the server session with the URL and the request
        let url: URL = URL(string: "\(Utils.serverAddress)/services/login.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        // Request parameters
        let paramString = "email=\(email)&password=\(password)"
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
                    self.delegate.responseReceived(parsedData)
                })
                
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
}
