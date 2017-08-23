//
//  LogInModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 07/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

// Protocol used for delegating the log in responses to the class that implements it
protocol LogInModelProtocol: class {
    func responseReceived(_ response: [String:Any])
}

// The class used for the authentication requests
class LogInModel: NSObject, URLSessionDataDelegate {
    weak var delegate: LogInModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // The request for authentication
    func checkCredentials(email: String, password: String) {
        self.data = NSMutableData()
        let url: URL = URL(string: "\(Utils.serverAddress)/services/login.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let paramString = "email=\(email)&password=\(password)"
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
