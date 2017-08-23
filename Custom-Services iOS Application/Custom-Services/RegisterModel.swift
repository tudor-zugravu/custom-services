//
//  RegisterModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 08/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

// Protocol used for delegating the registration responses to the class that implements it
protocol RegisterModelProtocol: class {
    func responseReceived(_ response: [String:Any])
}

// The class used for the registration requests
class RegisterModel: NSObject, URLSessionDataDelegate {
    weak var delegate: RegisterModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // The request for registration
    func registerRequest(name: String, email: String, password: String) {
        self.data = NSMutableData()
        let url: URL = URL(string: "\(Utils.serverAddress)/services/register.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let paramString = "name=\(name)&email=\(email)&password=\(password)"
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
                    self.delegate.responseReceived(parsedData)
                })
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
}
