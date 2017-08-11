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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        systemModel.requestSystemData()
    }
    
    func systemDataReceived(_ systemData: [String:Any]) {
        if (systemData["error"] as? String) != nil {
            let alert = UIAlertController(title: "Error",
                                          message: "System cannot be loaded at this moment" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        } else if let type = systemData["type"] as? String,
                    let hasCategories = systemData["has_categories"] as? String {
            UserDefaults.standard.set(type, forKey: "type")
            if UserDefaults.standard.value(forKey: "type") as! String == "location" {
                UserDefaults.standard.set(false, forKey: "hasCredit")
            } else {
                UserDefaults.standard.set(true, forKey: "hasCredit")
            }
            UserDefaults.standard.set(hasCategories == "1" ? true : false, forKey: "hasCategories")
            
            if hasCategories == "1" {
                systemModel.requestCategories()
            } else {
                if let email = UserDefaults.standard.value(forKey: "email") as? String,
                    let password = UserDefaults.standard.value(forKey: "password") as? String {
                    logInModel.checkCredentials(email: email, password: password)
                } else {
                    self.performSegue(withIdentifier: "initialLoginViewController", sender: nil)
                }
            }
        }
    }

    func categoriesReceived(_ systemData: [[String:Any]]) {
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
        } else {
            self.performSegue(withIdentifier: "initialLoginViewController", sender: nil)
        }
    }
    
    func responseReceived(_ response: [String:Any]) {
        if (response["status"] as? String) != nil {
            self.performSegue(withIdentifier: "initialLoginViewController", sender: nil)
        } else if let userId = Int((response["user_id"] as? String)!),
                    let name = response["name"] as? String,
                    let email = response["email"] as? String,
                    let password = response["password"] as? String {
            UserDefaults.standard.set(userId, forKey:"userId");
            UserDefaults.standard.set(name, forKey:"name");
            UserDefaults.standard.set(email, forKey:"email");
            UserDefaults.standard.set(password, forKey:"password");
            if UserDefaults.standard.bool(forKey: "hasCredit") == true {
                if let credit = Float((response["credit"] as? String)!) {
                    UserDefaults.standard.set(credit, forKey:"credit");
                }
            }
            
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
