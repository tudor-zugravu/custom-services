//
//  ProfileViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 08/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree

class ProfileViewController: UIViewController, ProfileModelProtocol {

    @IBOutlet weak var profilePictureImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var creditTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addCreditButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    let apiClient = BTAPIClient(authorization: "sandbox_44pm2mq7_9579dnmk65pnbf2z")
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
        customizeAppearance()
        
        // Adding the gesture recognizer that will dismiss the keyboard on an exterior tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if UserDefaults.standard.bool(forKey: "hasCredit") == false {
            addCreditButton.isHidden = true
            creditTextField.isHidden = true
        } else {
            addCreditButton.isHidden = false
            creditTextField.isHidden = false
            if let credit = UserDefaults.standard.value(forKey: "credit") as? Float {
                creditTextField.text = "Credit: \(credit) GBP"
            }
        }
        
        if let name = UserDefaults.standard.value(forKey: "name") as? String,
            let email = UserDefaults.standard.value(forKey: "email") as? String,
            let profilePicture = UserDefaults.standard.value(forKey: "profilePicture") as? String {
            nameTextField.text = name
            emailTextField.text = email
            
            if profilePicture != "" {
                let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(profilePicture)")
                if FileManager.default.fileExists(atPath: filename.path) {
                    profilePictureImage.image = UIImage(contentsOfFile: filename.path)
                } else {
                    // Download the profile picture, if exists
                    if let url = URL(string: "\(Utils.serverAddress)/resources/profile_pictures/\(profilePicture)") {
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
    
    func customizeAppearance() {
        navigationView.backgroundColor = Utils.instance.mainColour
        mainView.backgroundColor = Utils.instance.backgroundColour
        editButton.backgroundColor = Utils.instance.mainColour
        changePasswordButton.backgroundColor = Utils.instance.mainColour
        addCreditButton.backgroundColor = Utils.instance.mainColour
        bottomView.backgroundColor = Utils.instance.mainColour
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
        let creditPopUp = UIAlertController(title: "Amount to top up",
                                              message: "" as String, preferredStyle:.alert)
        creditPopUp.addTextField { (creditInput: UITextField!) -> Void in
            creditInput.keyboardType = UIKeyboardType.decimalPad
            creditInput.placeholder = ""
            
        }
        let topUp = UIAlertAction(title: "Top up", style: .default, handler: {
            alert -> Void in
            
            let creditInput = creditPopUp.textFields![0] as UITextField
            
            if creditInput.text != nil && creditInput.text != "" {
                if let inputAmount = Float(creditInput.text!) {
                    self.showDropIn(amount: inputAmount, clientTokenOrTokenizationKey: "sandbox_44pm2mq7_9579dnmk65pnbf2z")
                } else {
                    let alert = UIAlertController(title: "Invalid amount",
                                                  message: "Please enter a valid amount" as String, preferredStyle:.alert)
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
        
        creditPopUp.addAction(topUp)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        creditPopUp.addAction(cancel)
        self.present(creditPopUp, animated: true, completion: nil)
    }
    
    func detailsResponseReceived(_ response: [String:Any]) {
        if (response["error"] as? String) != nil && (response["error"] as? String) == "user_does_not_exist" {
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
        if (response["error"] as? String) != nil && (response["status"] as? String) == "user_does_not_exist" {
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
        if (response["error"] as? String) != nil && (response["error"] as? String) == "user_does_not_exist" {
            let alert = UIAlertController(title: "Error",
                                          message: "You have been disconnected" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
            self.signOut(Any.self)
        } else if let status = response["success"] as? Bool {
            if status {
                if let amount = response["amount"] as? Float {
                    creditTextField.text = "Credit: \(amount) GBP"
                    UserDefaults.standard.set(amount, forKey:"credit");
                    let alert = UIAlertController(title: "Transaction successful",
                                                  message: "Your credit has been topped up" as String, preferredStyle:.alert)
                    let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Transaction failed",
                                                  message: "Please try again" as String, preferredStyle:.alert)
                    let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Transaction failed",
                                              message: "Please try again" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Transaction failed",
                                          message: "Please try again" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showDropIn(amount: Float, clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                self.profileModel.addCredit(userId: (UserDefaults.standard.value(forKey: "userId") as? Int)!, amount: amount, paymentMethodNonce: (result.paymentMethod?.nonce)!)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
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
