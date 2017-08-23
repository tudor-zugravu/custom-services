//
//  ProfileModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 08/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

protocol ProfileModelProtocol: class {
    func detailsResponseReceived(_ response: [String:Any])
    func passwordResponseReceived(_ response: [String:Any])
    func creditResponseReceived(_ response: [String:Any])
}

class ProfileModel: NSObject, URLSessionDataDelegate {
    
    //properties
    weak var delegate: ProfileModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // Server request function for validating log in credentials
    func editDetails(userId: Int, name: String, email: String) {
        
        self.data = NSMutableData()
        
        // Setting up the server session with the URL and the request
        let url: URL = URL(string: "\(Utils.serverAddress)/services/update_user_details.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        // Request parameters
        let paramString = "userId=\(userId)&name=\(name)&email=\(email)"
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
                    self.delegate.detailsResponseReceived(parsedData)
                })
                
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
    
    // Server request function for validating log in credentials
    func changePassword(userId: Int, oldPassword: String, newPassword: String) {
        
        self.data = NSMutableData()
        
        // Setting up the server session with the URL and the request
        let url: URL = URL(string: "\(Utils.serverAddress)/services/change_password.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        // Request parameters
        let paramString = "userId=\(userId)&oldPassword=\(oldPassword)&newPassword=\(newPassword)"
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
                    self.delegate.passwordResponseReceived(parsedData)
                })
                
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
    
    // Server request function for validating log in credentials
    func addCredit(userId: Int, amount: Float, paymentMethodNonce: String) {
        
        self.data = NSMutableData()
        
        // Setting up the server session with the URL and the request
        let url: URL = URL(string: "\(Utils.serverAddress)/services/payment.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        request.httpBody = "userId=\(userId)&amount=\(amount)&payment_method_nonce=\(paymentMethodNonce)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
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
                    self.delegate.creditResponseReceived(parsedData)
                })
                
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
}
