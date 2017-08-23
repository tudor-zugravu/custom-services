//
//  ProfileModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 08/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

// Protocol used for delegating the profile information responses to the class that implements it
protocol ProfileModelProtocol: class {
    func detailsResponseReceived(_ response: [String:Any])
    func passwordResponseReceived(_ response: [String:Any])
    func creditResponseReceived(_ response: [String:Any])
}

// The class used for the profile requests
class ProfileModel: NSObject, URLSessionDataDelegate {
    weak var delegate: ProfileModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // The request for edition profile details
    func editDetails(userId: Int, name: String, email: String) {
        self.data = NSMutableData()
        let url: URL = URL(string: "\(Utils.serverAddress)/services/update_user_details.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let paramString = "userId=\(userId)&name=\(name)&email=\(email)"
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
                    self.delegate.detailsResponseReceived(parsedData)
                })
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
    
    // The request for changing a password
    func changePassword(userId: Int, oldPassword: String, newPassword: String) {
        self.data = NSMutableData()
        let url: URL = URL(string: "\(Utils.serverAddress)/services/change_password.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let paramString = "userId=\(userId)&oldPassword=\(oldPassword)&newPassword=\(newPassword)"
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
                    self.delegate.passwordResponseReceived(parsedData)
                })
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
    
    // The request for adding credit
    func addCredit(userId: Int, amount: Float, paymentMethodNonce: String) {
        self.data = NSMutableData()
        let url: URL = URL(string: "\(Utils.serverAddress)/services/payment.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.httpBody = "userId=\(userId)&amount=\(amount)&payment_method_nonce=\(paymentMethodNonce)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                DispatchQueue.main.async(execute: { () -> Void in
                    self.delegate.creditResponseReceived(parsedData)
                })
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
}
