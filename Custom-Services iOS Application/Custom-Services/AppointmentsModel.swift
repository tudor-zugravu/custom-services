//
//  AppointmentsModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 12/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

protocol AppointmentsModelProtocol: class {
    func appointmentsReceived(_ appointments: [[String:Any]], index: Int)
}

class AppointmentsModel: NSObject, URLSessionDataDelegate {
    
    //properties
    weak var delegate: AppointmentsModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // Server request function for validating log in credentials
    func requestAppointments(offerId: Int, index: Int) {
        self.data = NSMutableData()
        
        // Setting up the server session with the URL and the request
        let url: URL = URL(string: "\(Utils.serverAddress)/services/appointments.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        // Request parameters
        let paramString = "offerId=\(offerId)"
        
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
                    self.delegate.appointmentsReceived(parsedData, index: index)
                })
                
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
}
