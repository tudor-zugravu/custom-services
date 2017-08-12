//
//  RegisterViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 08/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, RegisterModelProtocol {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let registerModel = RegisterModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Adding the gesture recognizer that will dismiss the keyboard on an exterior tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // COPIED
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // COPIED
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        if nameTextField.text != nil && nameTextField.text != "" && emailTextField.text != nil && emailTextField.text != "" && confirmPasswordTextField.text != nil && confirmPasswordTextField.text != "" && passwordTextField.text != nil && passwordTextField.text != "" {
            if Utils.instance.isValidEmailFormat(email:emailTextField.text!) {
                if passwordTextField.text! == confirmPasswordTextField.text! {
                    registerModel.registerRequest(name: nameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!)
                } else {
                    let alert = UIAlertController(title: "Passwords do not match",
                                                  message: "Please enter matching passwords" as String, preferredStyle:.alert)
                    let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Incorrect email format",
                                              message: "Please enter a valid email address" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Empty fields",
                                          message: "Please fill in all fields" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func responseReceived(_ response: [String:Any]) {

        if let insertId = response["insertId"] as? Int {
            if insertId == 0 {
                let alert = UIAlertController(title: "Register failed",
                                              message: "Email address already registered with another account" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            } else {
                UserDefaults.standard.set(insertId, forKey:"userId");
                UserDefaults.standard.set(nameTextField.text!, forKey:"name");
                UserDefaults.standard.set(emailTextField.text!, forKey:"email");
                UserDefaults.standard.set(passwordTextField.text!, forKey:"password");
                UserDefaults.standard.set(0, forKey:"credit");
                UserDefaults.standard.set("", forKey:"profilePicture");
                self.performSegue(withIdentifier: "registerTabBarViewController", sender: nil)
            }
        } else {
            let alert = UIAlertController(title: "Register failed",
                                          message: "Please try again" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
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
