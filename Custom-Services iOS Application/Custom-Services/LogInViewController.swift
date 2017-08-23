//
//  LogInViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 08/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

// The class used for providind the functionalitites of the authentication ViewControler
class LogInViewController: UIViewController, LogInModelProtocol {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var mainLogo: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    let logInModel = LogInModel()
    
    // Function called upon the completion of the loading
    override func viewDidLoad() {
        super.viewDidLoad()
        logInModel.delegate = self
    }
    
    // Function called upon the completion of the view's rendering
    override func viewWillAppear(_ animated: Bool) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        customizeAppearance()
    }
    
    // Function when the view is about to disappear
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Function that performs the customisation of the visual elements
    func customizeAppearance() {
        navigationView.backgroundColor = Utils.instance.mainColour
        mainView.backgroundColor = Utils.instance.backgroundColour
        mainTitleLabel.text = Utils.instance.mainTitle
        bottomView.backgroundColor = Utils.instance.mainColour
        loginButton.backgroundColor = Utils.instance.mainColour
        registerButton.backgroundColor = Utils.instance.mainColour
        if Utils.instance.mainLogo != "" {
            let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(Utils.instance.mainLogo)").path
            mainLogo.image = UIImage(contentsOfFile: filename)
        } else {
            mainLogo.image = UIImage(named: "ban")
        }
    }
        
    @IBAction func loginButtonPressed(_ sender: Any) {
        if emailTextField.text != nil && emailTextField.text != "" && passwordTextField.text != nil && passwordTextField.text != "" {
            if Utils.instance.isValidEmailFormat(email:emailTextField.text!) {
                logInModel.checkCredentials(email: emailTextField.text!, password: passwordTextField.text!)
            } else {
                let alert = UIAlertController(title: "Incorrect email format",
                                              message: "Please enter a valid email address" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Empty fields",
                                          message: "Please enter both username and password" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func responseReceived(_ response: [String:Any]) {
        if (response["status"] as? String) != nil {
            let alert = UIAlertController(title: "Login failed",
                                              message: "Wrong username or password" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
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
                let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(profilePicture)")
                if FileManager.default.fileExists(atPath: filename.path) {
                    UserDefaults.standard.set(profilePicture, forKey:"profilePicture");
                } else {
                    // Download the profile picture, if exists
                    if let url = URL(string: "\(Utils.serverAddress)/resources/profile_pictures/\(profilePicture)") {
                        if let data = try? Data(contentsOf: url) {
                            var profilePic: UIImage
                            profilePic = UIImage(data: data)!
                            if let data = UIImagePNGRepresentation(profilePic) {
                                try? data.write(to: filename)
                                UserDefaults.standard.set(profilePicture, forKey:"profilePicture");
                            } else {
                                UserDefaults.standard.set("", forKey:"profilePicture");
                            }
                        } else {
                            UserDefaults.standard.set("", forKey:"profilePicture");
                        }
                    }
                }
            } else {
                UserDefaults.standard.set("", forKey:"profilePicture");
            }
            self.performSegue(withIdentifier: "logInTabBarViewController", sender: nil)
        } else {
            let alert = UIAlertController(title: "Login failed",
                                          message: "Wrong username or password" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // COPIED
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(show: true, notification: notification)
    }
    
    // COPIED
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(show: false, notification: notification)
    }
    
    // COPIED
    func adjustingHeight(show:Bool, notification:NSNotification) {
        if let userInfo = notification.userInfo, let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] {
            let duration = (durationValue as AnyObject).doubleValue
            let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            let options = UIViewAnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            
            self.bottomConstraint.constant = (keyboardFrame.height - 10) * (show ? 1 : 0)
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    // Called to dismiss the keyboard from the screen
    func dismissKeyboard(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
