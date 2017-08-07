//
//  InitialViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 06/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, SystemModelProtocol {
    
    let systemModel = SystemModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        UserDefaults.standard.set(categories, forKey:"categories");
        
        UserDefaults.standard.set(1, forKey:"userId");
        UserDefaults.standard.set("Tudor Zugravu", forKey:"name");
        UserDefaults.standard.set("tudor.zugravu@gmail.com", forKey:"email");
        UserDefaults.standard.set("tudor", forKey:"password");
        UserDefaults.standard.set(0.0, forKey:"credit");
        
        self.performSegue(withIdentifier: "initialTabBarViewController", sender: nil)
    }
}
