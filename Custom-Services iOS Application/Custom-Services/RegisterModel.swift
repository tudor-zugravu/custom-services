//
//  RegisterModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 08/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

protocol RegisterModelProtocol: class {
    func responseReceived(_ response: [String:Any])
}

class RegisterModel: NSObject, URLSessionDataDelegate {
    
    //properties
    weak var delegate: RegisterModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // Server request function for validating log in credentials
    func registerRequest(name: String, email: String, password: String) {
        
        self.data = NSMutableData()
        
        // Setting up the server session with the URL and the request
        let url: URL = URL(string: "https://custom-services.co.uk/services/register.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        // Request parameters
        let paramString = "name=\(name)&email=\(email)&password=\(password)"
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
