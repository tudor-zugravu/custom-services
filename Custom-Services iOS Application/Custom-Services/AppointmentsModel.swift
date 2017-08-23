//
//  AppointmentsModel.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 12/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

// Protocol used for delegating the appointment responses to the class that implements it
protocol AppointmentsModelProtocol: class {
    func appointmentsReceived(_ appointments: [[String:Any]], index: Int)
}

// The class used for the appointments requests
class AppointmentsModel: NSObject, URLSessionDataDelegate {
    weak var delegate: AppointmentsModelProtocol!
    var data : NSMutableData = NSMutableData()
    
    // The request for appointments
    func requestAppointments(offerId: Int, index: Int) {
        self.data = NSMutableData()
        let url: URL = URL(string: "\(Utils.serverAddress)/services/appointments.php")!
        let session = URLSession.shared
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let paramString = "offerId=\(offerId)"
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
                    self.delegate.appointmentsReceived(parsedData, index: index)
                })
            } catch let error as NSError {
                print(error)
            }
        })
        task.resume()
    }
}
