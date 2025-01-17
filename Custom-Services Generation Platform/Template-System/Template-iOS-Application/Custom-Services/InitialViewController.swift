//
//  InitialViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 06/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

// The class used for providind the functionalitites of the initial ViewControler
class InitialViewController: UIViewController, LogInModelProtocol, SystemModelProtocol {
    
    let systemModel = SystemModel()
    let logInModel = LogInModel()

    // Function called upon the completion of the loading
    override func viewDidLoad() {
        super.viewDidLoad()
        logInModel.delegate = self
        systemModel.delegate = self
    }
    
    // Function called upon the completion of the view's rendering
    override func viewDidAppear(_ animated: Bool) {
        systemModel.requestSystemData()
    }
    
    // Function called upon the receival of the system data, which are saved in the persistent memory of the bundle
    func systemDataReceived(_ systemData: [String:Any]) {
        if (systemData["error"] as? String) != nil {
            let alert = UIAlertController(title: "Error",
                                          message: "System cannot be loaded at this moment" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        } else if let type = systemData["type"] as? String,
            let hasCategories = systemData["has_categories"] as? String,
            let mainColour = systemData["main_colour"] as? String,
            let opaqueColour = systemData["opaque_colour"] as? String,
            let backgroundColour = systemData["background_colour"] as? String,
            let cellBackgroundColour = systemData["cell_background_colour"] as? String,
            let mainTitle = systemData["main_title"] as? String,
            let mainTabBarItemLabel = systemData["main_tab_title"] as? String,
            let geolocationNotifications = systemData["geolocation_notifications"] as? String {
            UserDefaults.standard.set(type, forKey: "type")
            if UserDefaults.standard.value(forKey: "type") as! String == "location" {
                UserDefaults.standard.set(false, forKey: "hasCredit")
            } else {
                UserDefaults.standard.set(true, forKey: "hasCredit")
            }
            UserDefaults.standard.set(hasCategories == "1" ? true : false, forKey: "hasCategories")
            var mainLogo = ""
            var navigationLogo = ""
            var mainTabBarItemLogo = ""
            if let auxImage = systemData["main_logo"] as? String {
                let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(auxImage)")
                if FileManager.default.fileExists(atPath: filename.path) {
                    mainLogo = auxImage
                } else {
                    if let url = URL(string: "\(Utils.serverAddress)/resources/system_images/\(auxImage)") {
                        if let data = try? Data(contentsOf: url) {
                            var auxPic: UIImage
                            auxPic = UIImage(data: data)!
                            if let data = UIImagePNGRepresentation(auxPic) {
                                try? data.write(to: filename)
                                mainLogo = auxImage
                            } else {
                                mainLogo = ""
                            }
                        } else {
                            mainLogo = ""
                        }
                    }
                }
            } else {
                mainLogo = ""
            }
            if let auxImage = systemData["navigation_logo"] as? String {
                let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(auxImage)")
                if FileManager.default.fileExists(atPath: filename.path) {
                    navigationLogo = auxImage
                } else {
                    if let url = URL(string: "\(Utils.serverAddress)/resources/system_images/\(auxImage)") {
                        if let data = try? Data(contentsOf: url) {
                            var auxPic: UIImage
                            auxPic = UIImage(data: data)!
                            if let data = UIImagePNGRepresentation(auxPic) {
                                try? data.write(to: filename)
                                navigationLogo = auxImage
                            } else {
                                navigationLogo = ""
                            }
                        } else {
                            navigationLogo = ""
                        }
                    }
                }
            } else {
                navigationLogo = ""
            }
            if let auxImage = systemData["main_tab_logo"] as? String {
                let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(auxImage)")
                if FileManager.default.fileExists(atPath: filename.path) {
                    mainTabBarItemLogo = auxImage
                } else {
                    if let url = URL(string: "\(Utils.serverAddress)/resources/system_images/\(auxImage)") {
                        if let data = try? Data(contentsOf: url) {
                            var auxPic: UIImage
                            auxPic = UIImage(data: data)!
                            if let data = UIImagePNGRepresentation(auxPic) {
                                try? data.write(to: filename)
                                mainTabBarItemLogo = auxImage
                            } else {
                                mainTabBarItemLogo = ""
                            }
                        } else {
                            mainTabBarItemLogo = ""
                        }
                    }
                }
            } else {
                mainTabBarItemLogo = ""
            }
            Utils.instance.setCustomisationParameters(mainColour: Int(mainColour, radix: 16)!, opaqueColour: Int(opaqueColour, radix: 16)!, backgroundColour: Int(backgroundColour, radix: 16)!, cellBackgroundColour: Int(cellBackgroundColour, radix: 16)!, mainTitle: mainTitle, mainLogo: mainLogo, navigationLogo: navigationLogo, mainTabBarItemLabel: mainTabBarItemLabel, mainTabBarItemLogo: mainTabBarItemLogo, geolocationNotifications: geolocationNotifications == "1" ? true : false)
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

    // Function called upon the receival of the category elements which are saved in the persistent storage of the app
    func categoriesReceived(_ systemData: [[String:Any]]) {
        var categories: [String] = []
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
    
    // Function called upon the authentification of the user, providing sessions by either presenting the offers view, or the login page
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
