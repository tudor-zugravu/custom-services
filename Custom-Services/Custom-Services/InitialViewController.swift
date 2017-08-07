//
//  InitialViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 06/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, LogInModelProtocol, SystemModelProtocol {
    
    let systemModel = SystemModel()
    let logInModel = LogInModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInModel.delegate = self
        systemModel.delegate = self
        systemModel.requestData()
        // Do any additional setup after loading the view.
    }

    func systemDataReceived(_ systemData: [[String:Any]]) {
        var categories: [String] = []
        
        // parse the received JSON and save the contacts
        for i in 0 ..< systemData.count {
            
            if let category = systemData[i]["category"] as? String {
                categories.append(category)
            }
        }
        
        if categories.isEmpty {
            UserDefaults.standard.set(false, forKey: "hasCategories")
        } else {
            UserDefaults.standard.set(true, forKey: "hasCategories")
            UserDefaults.standard.set(categories, forKey:"categories");
        }
        
        if let email = UserDefaults.standard.value(forKey: "email") as? String,
            let password = UserDefaults.standard.value(forKey: "password") as? String {
            logInModel.checkCredentials(email: email, password: password)
        }
    }
    
    func responseReceived(_ response: [String:Any]) {
        
        if (response["status"] as? String) != nil {
            self.performSegue(withIdentifier: "initialLoginViewController", sender: nil)
        } else if let userId = Int((response["user_id"] as? String)!),
                let name = response["name"] as? String,
                let credit = Float((response["credit"] as? String)!) {
            UserDefaults.standard.set(userId, forKey:"userId");
            UserDefaults.standard.set(name, forKey:"name");
            UserDefaults.standard.set(credit, forKey:"credit");
            
            if let profilePicture = response["profile_picture"] as? String {
                UserDefaults.standard.set(profilePicture, forKey:"profilePicture");
            } else {
                UserDefaults.standard.set("", forKey:"profilePicture");
            }
            self.performSegue(withIdentifier: "initialTabBarViewController", sender: nil)
        } else {
            self.performSegue(withIdentifier: "initialLoginViewController", sender: nil)
        }
    }
}
