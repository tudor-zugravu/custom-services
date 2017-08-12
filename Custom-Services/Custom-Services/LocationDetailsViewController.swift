//
//  LocationDetailsViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 11/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class LocationDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, FavouriteModelProtocol, RatingModelProtocol, CheckoutModelProtocol, AppointmentsModelProtocol {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dropdownMenuButton: DropMenuButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var categoryStack: UIStackView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var oneCategoryDiscountLabel: UILabel!
    @IBOutlet weak var timeIntervalStack: UIStackView!
    @IBOutlet weak var timeIntervalPickerView: UIPickerView!
    @IBOutlet weak var ratingStack: UIStackView!
    @IBOutlet weak var rateLocationButton: UIButton!
    @IBOutlet weak var checkoutButton: UIButton!
    
    var offers: [OfferModel] = []
    var categories: [String] = []
    var timeIntervals: [String] = []
    var locationId: Int = 0
    var rating: Int = 2
    var favourite: Bool = false
    var startingTime: String = "08:00"
    var duration: Int = 1
    let favouriteModel = FavouriteModel()
    let ratingModel = RatingModel()
    let checkoutModel = CheckoutModel()
    let appointmentsModel = AppointmentsModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favouriteModel.delegate = self
        ratingModel.delegate = self
        checkoutModel.delegate = self
        appointmentsModel.delegate = self
        self.initializeDropdown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Adding the gesture recognizer that will dismiss the keyboard on an exterior tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if (UserDefaults.standard.value(forKey: "storedOffers") != nil) {
            if let data = UserDefaults.standard.data(forKey: "storedOffers"),
                let offersAux = NSKeyedUnarchiver.unarchiveObject(with: data) as? [OfferModel] {
                offers = offersAux.filter({ $0.locationId == locationId})
            }
        }
        titleLabel.text = offers[0].name!
        ratingLabel.text = "\(String(format: "%.1f", offers[0].rating!))"
        addressLabel.text = offers[0].address;
        timeIntervalLabel.text = "\(offers[0].minTime!) - \(offers[0].maxTime!)"
        aboutLabel.text = offers[0].about
        checkoutButton.setTitle(UserDefaults.standard.value(forKey: "type") as! String == "product" ? "Sold out" : "Fully booked", for: UIControlState.disabled)
        
        if UserDefaults.standard.bool(forKey: "hasCategories") == true {
            categories = UserDefaults.standard.value(forKey: "categories")! as! [String]
            if offers.count == 1 {
                oneCategoryDiscountLabel.text = UserDefaults.standard.value(forKey: "type") as! String == "location" ? "\(Int(offers[0].discount!))% discount for \(offers[0].category!)" : "\(offers[0].discount!) GBP for \(offers[0].category!)"
                oneCategoryDiscountLabel.isHidden = false
                categoryStack.isHidden = true
            } else {
                categoryLabel.text = UserDefaults.standard.value(forKey: "type") as! String == "location" ? "The discount for" : "The price for"
                oneCategoryDiscountLabel.isHidden = true
                categoryStack.isHidden = false
                categoryPickerView.dataSource = self
                categoryPickerView.delegate = self
                categoryPickerView.selectRow(0, inComponent: 0, animated: false)
                discountLabel.text = UserDefaults.standard.value(forKey: "type") as! String == "location" ? "\(Int(offers[0].discount!))%" : "\(offers[0].discount!) GBP"
            }
        } else {
            oneCategoryDiscountLabel.text = UserDefaults.standard.value(forKey: "type") as! String == "location" ? "\(Int(offers[0].discount!))% discount for \(offers[0].category!)" : "\(offers[0].discount!) GBP for \(offers[0].category!)"
            oneCategoryDiscountLabel.isHidden = false
            categoryStack.isHidden = true
        }
        if UserDefaults.standard.value(forKey: "type") as! String != "location" && offers[0].quantity! == 0 {
            checkoutButton.isEnabled = false;
            checkoutButton.alpha = 0.5
        }
        if UserDefaults.standard.value(forKey: "type") as! String == "location" {
            ratingStack.isHidden = false
            rateLocationButton.isHidden = false
            checkoutButton.isHidden = true
        } else {
            ratingStack.isHidden = true
            rateLocationButton.isHidden = true
            checkoutButton.isHidden = false
        }
        if UserDefaults.standard.value(forKey: "type") as! String == "service" {
            appointmentsModel.requestAppointments(offerId: offers[0].id!, index: 0)
            startingTime = offers[0].minTime!
            duration = offers[0].appointmentDuration!
            timeIntervalStack.isHidden = false
            timeIntervalPickerView.dataSource = self
            timeIntervalPickerView.delegate = self
            timeIntervalPickerView.selectRow(0, inComponent: 0, animated: false)
        } else {
            timeIntervalStack.isHidden = true
        }
        
        //TODO: add global default photos
        logoImage.image = offers[0].offerLogo != "" ? UIImage(named: offers[0].offerLogo!) : UIImage(named: "stChristophersLogo")
        locationImage.image = offers[0].offerImage != "" ? UIImage(named: offers[0].offerImage!) : UIImage(named: "stChristophersImage")
        if (favourite == true) {
            favouriteButton.setImage(UIImage(named: "fullHeart.png"), for: UIControlState.normal)
        } else {
            favouriteButton.setImage(UIImage(named: "emptyHeart.png"), for: UIControlState.normal)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPickerView {
            return offers.count
        }
        return timeIntervals.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPickerView {
            return offers[row].category!
        }
        return timeIntervals[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPickerView {
            discountLabel.text = UserDefaults.standard.value(forKey: "type") as! String == "location" ? "\(Int(offers[row].discount!))%" : "\(offers[row].discount!) GBP"
            if UserDefaults.standard.value(forKey: "type") as! String != "location" && offers[row].quantity! == 0 {
                timeIntervals.removeAll(keepingCapacity: false)
                timeIntervalPickerView.reloadAllComponents()
                checkoutButton.isEnabled = false
                checkoutButton.alpha = 0.5
            } else {
                checkoutButton.isEnabled = true
                checkoutButton.alpha = 1
                appointmentsModel.requestAppointments(offerId: offers[row].id!, index: row)
                startingTime = offers[row].minTime!
                duration = offers[row].appointmentDuration!
            }
        }
    }
    
    func favouriteSelected(_ result: NSString, tag: Int) {
        if result == "1" {
            favourite = favourite ? false : true
            favouriteButton.setImage(UIImage(named: favourite == false ? "emptyHeart.png" : "fullHeart.png"), for: UIControlState.normal)
        }
    }
    
    func appointmentsReceived(_ appointments: [[String:Any]], index: Int) {
        var appointmentsAux: [Int] = []
        
        for i in 0 ..< appointments.count {
            if let startingTime = Int((appointments[i]["appointment_starting"] as? String)!) {
                appointmentsAux.append(startingTime)
            }
        }
        timeIntervals = Utils.instance.getTimeIntervals(startingTime: offers[index].minTime!, endingTime: offers[index].maxTime!, duration: offers[index].appointmentDuration!, appointments: appointmentsAux)
        timeIntervalPickerView.reloadAllComponents()
    }
    
    func ratingResponse(_ result: NSString) {
        if result == "true" {
            ratingLabel.text = "\(rating)"
            let alert = UIAlertController(title: "Success",
                                          message: "Thank you for your feedback" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error",
                                          message: "Please try again" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func productCheckoutResponse(_ result: [String:Any]) {
        if let status = result["status"] as? String {
            switch status {
                case "success":
                    let alert = UIAlertController(title: "Offer purchased",
                                                  message: "Voucher added to your receipts" as String, preferredStyle:.alert)
                    let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "credit") as! Float - offers[categoryPickerView.selectedRow(inComponent: 0)].discount!, forKey: "credit")
                    offers[categoryPickerView.selectedRow(inComponent: 0)].quantity! -= 1
                    if offers[categoryPickerView.selectedRow(inComponent: 0)].quantity! == 0 {
                        checkoutButton.isEnabled = false
                        checkoutButton.alpha = 0.5
                    }
                    break
                case "offer_expired":
                    let alert = UIAlertController(title: "Unsuccessful",
                                                  message: "Offer has sold out" as String, preferredStyle:.alert)
                    let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                    offers[categoryPickerView.selectedRow(inComponent: 0)].quantity = 0
                    checkoutButton.isEnabled = false
                    checkoutButton.alpha = 0.5
                    break
                case "user_does_not_exist":
                    let alert = UIAlertController(title: "Error",
                                                  message: "You have been disconnected" as String, preferredStyle:.alert)
                    let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                    self.signOut(Any.self)
                    break
                case "same_quantity":
                    print("checkout error: \(status)")
                    showErrorMessage()
                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "credit") as! Float - offers[categoryPickerView.selectedRow(inComponent: 0)].discount!, forKey: "credit")
                    break
                case "no_receipt":
                    print("checkout error: \(status)")
                    showErrorMessage()
                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "credit") as! Float - offers[categoryPickerView.selectedRow(inComponent: 0)].discount!, forKey: "credit")
                    offers[categoryPickerView.selectedRow(inComponent: 0)].quantity! -= 1
                    if offers[categoryPickerView.selectedRow(inComponent: 0)].quantity! == 0 {
                        checkoutButton.isEnabled = false
                        checkoutButton.alpha = 0.5
                    }
                    break
                case "insufficient_credit":
                    let alert = UIAlertController(title: "Insufficient credit",
                                                  message: "Please top up" as String, preferredStyle:.alert)
                    let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                    break
                default:
                    print("checkout error: \(status)")
                    showErrorMessage()
                    break
            }
        } else {
            showErrorMessage()
        }
    }
    
    func serviceCheckoutResponse(_ result: [String:Any]) {
        if let status = result["status"] as? String {
            switch status {
            case "success":
                let alert = UIAlertController(title: "Offer purchased",
                                              message: "Voucher added to your receipts" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "credit") as! Float - offers[categoryPickerView.selectedRow(inComponent: 0)].discount!, forKey: "credit")
                timeIntervals.remove(at: self.timeIntervalPickerView.selectedRow(inComponent: 0))
                offers[categoryPickerView.selectedRow(inComponent: 0)].quantity! -= 1
                timeIntervalPickerView.reloadAllComponents()
                if offers[categoryPickerView.selectedRow(inComponent: 0)].quantity! == 0 {
                    checkoutButton.isEnabled = false
                    checkoutButton.alpha = 0.5
                }
                break
            case "offer_expired":
                let alert = UIAlertController(title: "Unsuccessful",
                                              message: "Offer has sold out" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
                offers[categoryPickerView.selectedRow(inComponent: 0)].quantity = 0
                timeIntervals.removeAll(keepingCapacity: false)
                timeIntervalPickerView.reloadAllComponents()
                checkoutButton.isEnabled = false
                checkoutButton.alpha = 0.5
                break
            case "user_does_not_exist":
                let alert = UIAlertController(title: "Error",
                                              message: "You have been disconnected" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
                self.signOut(Any.self)
                break
            case "same_quantity":
                print("checkout error: \(status)")
                showErrorMessage()
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "credit") as! Float - offers[categoryPickerView.selectedRow(inComponent: 0)].discount!, forKey: "credit")
                break
            case "no_receipt":
                print("checkout error: \(status)")
                showErrorMessage()
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "credit") as! Float - offers[categoryPickerView.selectedRow(inComponent: 0)].discount!, forKey: "credit")
                offers[categoryPickerView.selectedRow(inComponent: 0)].quantity! -= 1
                if offers[categoryPickerView.selectedRow(inComponent: 0)].quantity! == 0 {
                    checkoutButton.isEnabled = false
                    checkoutButton.alpha = 0.5
                }
                break
            case "insufficient_credit":
                let alert = UIAlertController(title: "Insufficient credit",
                                              message: "Please top up" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
                break
            default:
                print("checkout error: \(status)")
                showErrorMessage()
                break
            }
        } else {
            showErrorMessage()
        }
    }
    
    func showErrorMessage() {
        let alert = UIAlertController(title: "Error",
                                      message: "Please try again" as String, preferredStyle:.alert)
        let done = UIAlertAction(title: "Done", style: .default, handler: nil)
        alert.addAction(done)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func starButtonPressed(_ sender: AnyObject) {
        (self.view.viewWithTag(2) as? UIButton)?.setImage(UIImage(named: sender.tag >= 2 ? "starRatingFull.png" : "starRatingEmpty.png"), for: UIControlState.normal)
        (self.view.viewWithTag(3) as? UIButton)?.setImage(UIImage(named: sender.tag >= 3 ? "starRatingFull.png" : "starRatingEmpty.png"), for: UIControlState.normal)
        (self.view.viewWithTag(4) as? UIButton)?.setImage(UIImage(named: sender.tag >= 4 ? "starRatingFull.png" : "starRatingEmpty.png"), for: UIControlState.normal)
        (self.view.viewWithTag(5) as? UIButton)?.setImage(UIImage(named: sender.tag == 5 ? "starRatingFull.png" : "starRatingEmpty.png"), for: UIControlState.normal)
        self.rating = sender.tag
    }
    
    @IBAction func getDirectionsButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func checkoutButtonPressed(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "type") as! String == "product" {
            let alert = UIAlertController(title: "Checkout",
                                          message: "Purchase this offer for \(offers[categoryPickerView.selectedRow(inComponent: 0)].discount!) GBP?" as String, preferredStyle:.alert)
            let yes = UIAlertAction(title: "Yes", style: .default, handler: {
                alert -> Void in
                self.checkoutModel.productCheckout(offerId: self.offers[self.categoryPickerView.selectedRow(inComponent: 0)].id!)
            })
            alert.addAction(yes)
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Checkout",
                                          message: "Book an appointment for \(offers[categoryPickerView.selectedRow(inComponent: 0)].discount!) GBP in between \(timeIntervals[timeIntervalPickerView.selectedRow(inComponent: 0)])?" as String, preferredStyle:.alert)
            let yes = UIAlertAction(title: "Yes", style: .default, handler: {
                alert -> Void in
                self.checkoutModel.serviceCheckout(offerId: self.offers[self.categoryPickerView.selectedRow(inComponent: 0)].id!, appointment: Utils.instance.getIndex(startingTime: self.startingTime, duration: self.duration, time: self.timeIntervals[self.timeIntervalPickerView.selectedRow(inComponent: 0)]))
            })
            alert.addAction(yes)
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func rateLocationButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Rating",
                                      message: "Give \(offers[0].name!) a \(rating) star rating?" as String, preferredStyle:.alert)
        let yes = UIAlertAction(title: "Yes", style: .default, handler: {
            alert -> Void in
            self.ratingModel.sendRating(locationId: self.offers[0].locationId!, rating: self.rating)
        })
        alert.addAction(yes)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func favouriteButtonPressed(_ sender: Any) {
        favouriteModel.sendFavourite(locationId: offers[0].locationId!, favourite: favourite ? 0 : 1, tag: 0)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    // Create the dropdown menu
    func initializeDropdown() {
        dropdownMenuButton.initMenu(["View Profile", "Contact Us", "Sign Out"], actions: [
            ({ () -> (Void) in
                self.performSegue(withIdentifier: "locationDetailsProfileViewController", sender: nil)
            }),
            ({ () -> (Void) in print("CONTACT US!") }),
            ({ () -> (Void) in
                self.signOut(Any.self)
            })])
    }
    
    // Called to dismiss the keyboard from the screen
    func dismissMenu(gestureRecognizer: UITapGestureRecognizer) {
        if !self.dropdownMenuButton.table.frame.contains(gestureRecognizer.location(in: self.view)) && !self.dropdownMenuButton.frame.contains(gestureRecognizer.location(in: self.view)) {
            dropdownMenuButton.hideMenu()
        }
    }

    func signOut(_ sender: Any) {
        
        Utils.instance.signOut()
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
