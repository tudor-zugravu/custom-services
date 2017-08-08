//
//  ProfileViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 08/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, ProfileModelProtocol {

    @IBOutlet weak var profilePictureImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var creditTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let profileModel = ProfileModel()
    var newPass: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileModel.delegate = self
        
        profilePictureImage.layer.shadowColor = UIColor.lightGray.cgColor
        profilePictureImage.layer.shadowOffset = CGSize(width:-2, height:2)
        profilePictureImage.layer.shadowRadius = 3
        profilePictureImage.layer.shadowOpacity = 0.6
        profilePictureImage.layer.borderWidth = 1
        profilePictureImage.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Adding the gesture recognizer that will dismiss the keyboard on an exterior tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if let name = UserDefaults.standard.value(forKey: "name") as? String,
            let email = UserDefaults.standard.value(forKey: "email") as? String,
            let profilePicture = UserDefaults.standard.value(forKey: "profilePicture") as? String,
            let credit = UserDefaults.standard.value(forKey: "credit") as? Float {
            nameTextField.text = name
            emailTextField.text = email
            creditTextField.text = "Credit: \(credit)"
            
            if profilePicture != "" {
                let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(profilePicture)")
                if FileManager.default.fileExists(atPath: filename.path) {
                    profilePictureImage.image = UIImage(contentsOfFile: filename.path)
                } else {
                    // Download the profile picture, if exists
                    if let url = URL(string: "http://46.101.29.197/profile_pictures/\(profilePicture)") {
                        if let data = try? Data(contentsOf: url) {
                            var profilePic: UIImage
                            profilePic = UIImage(data: data)!
                            if let data = UIImagePNGRepresentation(profilePic) {
                                try? data.write(to: filename)
                                profilePictureImage.image = UIImage(contentsOfFile: profilePicture)
                            }
                        }
                    }
                }
            }
        }
        
        // COPIED
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // COPIED
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @IBAction func editButtonPressed(_ sender: Any) {
        if editButton.titleLabel?.text == "Edit details" {
            nameTextField.isEnabled = true
            emailTextField.isEnabled = true
            editButton.setTitle("Save changes", for: UIControlState.normal)
        } else {
            if nameTextField.text != UserDefaults.standard.value(forKey: "name") as? String || emailTextField.text != UserDefaults.standard.value(forKey: "email") as? String {
                if nameTextField.text != nil && nameTextField.text != "" && emailTextField.text != nil && emailTextField.text != "" {
                    if Utils.instance.isValidEmailFormat(email:emailTextField.text!) {
                        profileModel.editDetails(userId: (UserDefaults.standard.value(forKey: "userId") as? Int)!, name: nameTextField.text!, email: emailTextField.text!)
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
            } else {
                nameTextField.isEnabled = false
                emailTextField.isEnabled = false
                editButton.setTitle("Edit details", for: UIControlState.normal)
            }
        }
    }
    
    @IBAction func changePasswordButtonPressed(_ sender: Any) {
        let passwordPopUp = UIAlertController(title: "Change password",
                                      message: "" as String, preferredStyle:.alert)
        
        passwordPopUp.addTextField { (oldPassword: UITextField!) -> Void in
            oldPassword.placeholder = "Current password"
        }
        passwordPopUp.addTextField { (newPassword: UITextField!) -> Void in
            newPassword.placeholder = "New password"
        }
        passwordPopUp.addTextField { (confirmNewPassword: UITextField!) -> Void in
            confirmNewPassword.placeholder = "Confirm new password"
        }
        
        let update = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            let oldPassword = passwordPopUp.textFields![0] as UITextField
            let newPassword = passwordPopUp.textFields![1] as UITextField
            let confirmNewPassword = passwordPopUp.textFields![2] as UITextField
            
            if oldPassword.text != nil && oldPassword.text != "" && newPassword.text != nil && newPassword.text != "" && confirmNewPassword.text != nil && confirmNewPassword.text != "" {
                if newPassword.text == confirmNewPassword.text {
                    self.newPass = newPassword.text!
                    self.profileModel.changePassword(userId: (UserDefaults.standard.value(forKey: "userId") as? Int)!, oldPassword: oldPassword.text!, newPassword: newPassword.text!)
                } else {
                    let alert = UIAlertController(title: "Passwords do not match",
                                                  message: "Please enter matching passwords" as String, preferredStyle:.alert)
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
        })
        
        passwordPopUp.addAction(update)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        passwordPopUp.addAction(cancel)
        self.present(passwordPopUp, animated: true, completion: nil)
    }
    
    @IBAction func addCreditButtonPressed(_ sender: Any) {
        
    }
    
    func detailsResponseReceived(_ response: [String:Any]) {
        if (response["status"] as? String) != nil && (response["status"] as? String) == "user_does_not_exist" {
            let alert = UIAlertController(title: "Error",
                                          message: "You have been disconnected" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
            self.signOut(Any.self)
        } else if let status = response["status"] as? Bool {
            if status == false {
                let alert = UIAlertController(title: "Update failed",
                                              message: "The email address is already used" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            } else {
                nameTextField.isEnabled = false
                emailTextField.isEnabled = false
                editButton.setTitle("Edit details", for: UIControlState.normal)
                UserDefaults.standard.set(nameTextField.text!, forKey:"name");
                UserDefaults.standard.set(emailTextField.text!, forKey:"email");
            }
        } else {
            let alert = UIAlertController(title: "Update failed",
                                          message: "Please try again" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func passwordResponseReceived(_ response: [String:Any]) {
        print(response)
        if (response["status"] as? String) != nil && (response["status"] as? String) == "user_does_not_exist" {
            let alert = UIAlertController(title: "Error",
                                          message: "You have been disconnected" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
            self.signOut(Any.self)
        } else if let status = response["status"] as? Bool {
            if status == false {
                let alert = UIAlertController(title: "Update failed",
                                              message: "Incorrect password" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            } else {
                UserDefaults.standard.set(self.newPass, forKey:"password");
                let alert = UIAlertController(title: "Success",
                                              message: "Password updated" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Update failed",
                                          message: "Please try again" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func creditResponseReceived(_ response: [String:Any]) {
        print(response)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }

    func signOut(_ sender: Any) {
        
        Utils.instance.signOut()
        _ = self.navigationController?.popToRootViewController(animated: true)
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
