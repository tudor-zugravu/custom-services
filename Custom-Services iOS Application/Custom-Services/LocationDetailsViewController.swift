//
//  LocationDetailsViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 11/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import HDAugmentedReality
import UserNotifications

// The class used for providind the functionalitites of the location details ViewControler
class LocationDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, ARDataSource, FavouriteModelProtocol, LocationRatingModelProtocol, CheckoutModelProtocol, AppointmentsModelProtocol, DirectionsModelProtocol, CheckpointViewDelegate {

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
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var getDirectionsButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    var offers: [OfferModel] = []
    var categories: [String] = []
    var timeIntervals: [String] = []
    var checkpoints: [Checkpoint] = []
    var visibleCheckpoints: [Checkpoint] = []
    var locationId: Int = 0
    var rating: Int = 2
    var selectedCategory: Int = 0
    var favourite: Bool = false
    var startingTime: String = "08:00"
    var duration: Int = 1
    var noCheckpoints = 0
    var prevCheckpoint: Checkpoint?
    var nextCheckpoint: Checkpoint?
    var isVR: Bool = false
    let favouriteModel = FavouriteModel()
    let ratingModel = RatingModel()
    let checkoutModel = CheckoutModel()
    let appointmentsModel = AppointmentsModel()
    let directionsModel = DirectionsModel()
    let locationManager = CLLocationManager()
    let arViewController = ARViewController()
    let hour = Calendar.current.component(.hour, from: Date()) < 10 ? "0\(Calendar.current.component(.hour, from: Date()))" : "\(Calendar.current.component(.hour, from: Date()))"
    let minute = Calendar.current.component(.minute, from: Date()) < 10 ? "0\(Calendar.current.component(.minute, from: Date()))" : "\(Calendar.current.component(.minute, from: Date()))"
    var currentTime = ""
    
    // Function called upon the completion of the loading
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTime = "\(hour):\(minute)"
        favouriteModel.delegate = self
        ratingModel.delegate = self
        checkoutModel.delegate = self
        appointmentsModel.delegate = self
        directionsModel.delegate = self
        self.initializeDropdown()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    // Function called upon the completion of the view's rendering
    override func viewWillAppear(_ animated: Bool) {
        customizeAppearance()
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
        if UserDefaults.standard.value(forKey: "type") as! String != "location" {
            if currentTime > offers[0].maxTime! {
                checkoutButton.isEnabled = false;
                checkoutButton.alpha = 0.5
                checkoutButton.setTitle("Offer expired", for: UIControlState.disabled)
            } else {
                checkoutButton.isEnabled = true;
                checkoutButton.alpha = 1
                checkoutButton.setTitle(UserDefaults.standard.value(forKey: "type") as! String == "product" ? "Sold out" : "Fully booked", for: UIControlState.disabled)
            }
        }
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
            oneCategoryDiscountLabel.text = UserDefaults.standard.value(forKey: "type") as! String == "location" ? "\(Int(offers[0].discount!))% discount" : "\(offers[0].discount!) GBP"
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
        if offers[0].offerLogo! != "" {
            let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(offers[0].offerLogo!)").path
            self.logoImage.image = UIImage(contentsOfFile: filename)
        } else {
            self.logoImage.image = UIImage(named: "ban")
        }
        if offers[0].offerImage! != "" {
            let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(offers[0].offerImage!)").path
            self.locationImage.image = UIImage(contentsOfFile: filename)
        } else {
            self.locationImage.image = UIImage(named: "ban")
        }
        if (favourite == true) {
            favouriteButton.setImage(UIImage(named: "fullHeart.png"), for: UIControlState.normal)
        } else {
            favouriteButton.setImage(UIImage(named: "emptyHeart.png"), for: UIControlState.normal)
        }
    }
    
    // Function that performs the customisation of the visual elements
    func customizeAppearance() {
        navigationView.backgroundColor = Utils.instance.mainColour
        mainTitleLabel.text = Utils.instance.mainTitle
        scrollView.backgroundColor = Utils.instance.backgroundColour
        checkoutButton.backgroundColor = Utils.instance.mainColour
        rateLocationButton.backgroundColor = Utils.instance.mainColour
        getDirectionsButton.backgroundColor = Utils.instance.mainColour
        bottomView.backgroundColor = Utils.instance.mainColour
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
            selectedCategory = row
            discountLabel.text = UserDefaults.standard.value(forKey: "type") as! String == "location" ? "\(Int(offers[row].discount!))%" : "\(offers[row].discount!) GBP"
            if UserDefaults.standard.value(forKey: "type") as! String != "location" && offers[row].quantity! == 0 {
                timeIntervals.removeAll(keepingCapacity: false)
                timeIntervalPickerView.reloadAllComponents()
                checkoutButton.isEnabled = false
                checkoutButton.alpha = 0.5
            } else {
                if currentTime > offers[row].maxTime! {
                    checkoutButton.isEnabled = false;
                    checkoutButton.alpha = 0.5
                    checkoutButton.setTitle("Offer expired", for: UIControlState.disabled)
                } else {
                    checkoutButton.isEnabled = true;
                    checkoutButton.alpha = 1
                    checkoutButton.setTitle(UserDefaults.standard.value(forKey: "type") as! String == "product" ? "Sold out" : "Fully booked", for: UIControlState.disabled)
                }
                if UserDefaults.standard.value(forKey: "type") as! String == "service" {
                    appointmentsModel.requestAppointments(offerId: offers[row].id!, index: row)
                    startingTime = offers[row].minTime!
                    duration = offers[row].appointmentDuration!
                }
            }
        } else {
            checkTimeInterval(time: timeIntervals[timeIntervalPickerView.selectedRow(inComponent: 0)])
        }
    }
    
    func checkTimeInterval(time: String) {
        var DateArray = time.components(separatedBy: CharacterSet(charactersIn: "-:"))
        var components = DateComponents()
        components.year = Calendar.current.component(.year, from: Date())
        components.month = Calendar.current.component(.month, from: Date())
        components.day = Calendar.current.component(.day, from: Date())
        components.hour = Int(DateArray[0])!
        components.minute = Int(DateArray[1])!
        components.second = Calendar.current.component(.second, from: Date())
        let date = Calendar.current.date(from: components)!
        if date.timeIntervalSinceNow < 10 {
            checkoutButton.setTitle("Expired time interval", for: UIControlState.disabled)
            checkoutButton.isEnabled = false
            checkoutButton.alpha = 0.5
        } else {
            checkoutButton.setTitle("Fully booked", for: UIControlState.disabled)
            checkoutButton.isEnabled = true
            checkoutButton.alpha = 1
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
        if timeIntervals.count == 0 {
            checkoutButton.setTitle("Fully booked", for: UIControlState.disabled)
            checkoutButton.isEnabled = false
            checkoutButton.alpha = 0.5
        } else {
            checkTimeInterval(time: timeIntervals[0])
        }
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
                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "credit") as! Float - offers[selectedCategory].discount!, forKey: "credit")
                    offers[selectedCategory].quantity! -= 1
                    if offers[selectedCategory].quantity! == 0 {
                        checkoutButton.isEnabled = false
                        checkoutButton.alpha = 0.5
                    }
                    if let insertId = result["insertId"] as? Int {
                        setNotification(offer: offers[selectedCategory], id: insertId)
                    }
                    break
                case "offer_expired":
                    let alert = UIAlertController(title: "Unsuccessful",
                                                  message: "Offer has sold out" as String, preferredStyle:.alert)
                    let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                    offers[selectedCategory].quantity = 0
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
                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "credit") as! Float - offers[selectedCategory].discount!, forKey: "credit")
                    break
                case "no_receipt":
                    print("checkout error: \(status)")
                    showErrorMessage()
                    UserDefaults.standard.set(UserDefaults.standard.value(forKey: "credit") as! Float - offers[selectedCategory].discount!, forKey: "credit")
                    offers[selectedCategory].quantity! -= 1
                    if offers[selectedCategory].quantity! == 0 {
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
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "credit") as! Float - offers[selectedCategory].discount!, forKey: "credit")
                timeIntervals.remove(at: self.timeIntervalPickerView.selectedRow(inComponent: 0))
                offers[selectedCategory].quantity! -= 1
                timeIntervalPickerView.reloadAllComponents()
                if offers[selectedCategory].quantity! == 0 {
                    checkoutButton.isEnabled = false
                    checkoutButton.alpha = 0.5
                }
                if let insertId = result["insertId"] as? Int {
                    setNotification(offer: offers[selectedCategory], id: insertId)
                }
                break
            case "offer_expired":
                let alert = UIAlertController(title: "Unsuccessful",
                                              message: "Offer has sold out" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
                offers[selectedCategory].quantity = 0
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
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "credit") as! Float - offers[selectedCategory].discount!, forKey: "credit")
                break
            case "no_receipt":
                print("checkout error: \(status)")
                showErrorMessage()
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "credit") as! Float - offers[selectedCategory].discount!, forKey: "credit")
                offers[selectedCategory].quantity! -= 1
                if offers[selectedCategory].quantity! == 0 {
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
    
    func setNotification(offer: OfferModel, id: Int) {
        var minute = 0
        var hour = 0
        if UserDefaults.standard.value(forKey: "type") as! String != "service" {
            let DateArray = offer.minTime!.components(separatedBy: ":")
            hour = Int(DateArray[0])!
            minute = Int(DateArray[1])!
        } else {
            let DateArray = timeIntervals[timeIntervalPickerView.selectedRow(inComponent: 0)].components(separatedBy: CharacterSet(charactersIn: "-:"))
            hour = Int(DateArray[0])!
            minute = Int(DateArray[1])!
        }
        var components = DateComponents()
        components.year = Calendar.current.component(.year, from: Date())
        components.month = Calendar.current.component(.month, from: Date())
        components.day = Calendar.current.component(.day, from: Date())
        components.hour = hour
        components.minute = minute
        components.second = Calendar.current.component(.second, from: Date())
        let date = Calendar.current.date(from: components)!
        var timeInterval = 10.0
        if date.timeIntervalSinceNow > 900 {
            timeInterval = date.timeIntervalSinceNow - 900
        }
        let notification = UNMutableNotificationContent()
        notification.title = "\(offer.name!)"
        notification.body = "Your receipt is due soon"
        notification.categoryIdentifier = "appointmentDue.category"
        notification.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "newAppointment\(id)", content: notification, trigger: trigger)
        UNUserNotificationCenter.current().add(request){
            (error) in
            if error != nil{
                print ("Add notification error: \(error?.localizedDescription)")
            }
        }
    }

    @IBAction func starButtonPressed(_ sender: AnyObject) {
        (self.view.viewWithTag(2) as? UIButton)?.setImage(UIImage(named: sender.tag >= 2 ? "starRatingFull.png" : "starRatingEmpty.png"), for: UIControlState.normal)
        (self.view.viewWithTag(3) as? UIButton)?.setImage(UIImage(named: sender.tag >= 3 ? "starRatingFull.png" : "starRatingEmpty.png"), for: UIControlState.normal)
        (self.view.viewWithTag(4) as? UIButton)?.setImage(UIImage(named: sender.tag >= 4 ? "starRatingFull.png" : "starRatingEmpty.png"), for: UIControlState.normal)
        (self.view.viewWithTag(5) as? UIButton)?.setImage(UIImage(named: sender.tag == 5 ? "starRatingFull.png" : "starRatingEmpty.png"), for: UIControlState.normal)
        self.rating = sender.tag
    }
    
    @IBAction func getDirectionsButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Get directions using",
                                      message: "" as String, preferredStyle:.alert)
        let appleMaps = UIAlertAction(title: "Apple Maps", style: .default, handler: {
            alert -> Void in
            self.openMapForPlace()
        })
        alert.addAction(appleMaps)
        let googleMaps = UIAlertAction(title: "Google Maps", style: .default, handler: {
            alert -> Void in
            UIApplication.shared.open(URL(string:"https://www.google.com/maps/dir/?api=1&destination=\(self.offers[0].latitude!),\(self.offers[0].longitude!)")!, options: [:], completionHandler: nil)
        })
        alert.addAction(googleMaps)
        let augmentedReality = UIAlertAction(title: "Augmented Reality", style: .default, handler: {
            alert -> Void in
            if let currentLocation = self.locationManager.location {
                self.directionsModel.requestOffers(currLatitude: currentLocation.coordinate.latitude, currLongitude: currentLocation.coordinate.longitude, destLatitude: self.offers[0].latitude!, destLongitude: self.offers[0].longitude!)
            }
        })
        alert.addAction(augmentedReality)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func directionsReceived(_ directions: [[String:AnyObject]], startingLocation: CLLocation) {
        var checkpointsAux: [Checkpoint] = [Checkpoint(location: startingLocation, checkpointLabel: "Starting Point", color: "red")]
        var index = 0
        for step in directions {
            if let coordinates = step["end_location"] as? [String:Any] {
                if let latitude = coordinates["lat"] as? Double,
                    let longitude = coordinates["lng"] as? Double {
                    if index == directions.count - 1 {
                        checkpointsAux.append(Checkpoint(location: CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)), checkpointLabel: "Final destination", color: "green"))
                    } else {
                        checkpointsAux.append(Checkpoint(location: CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)), checkpointLabel: "Checkpoint \(index + 1)", color: "yellow"))
                    }
                } else {
                    print("no latitude,longitude")
                }
            } else {
                print("no coordinates")
            }
            index += 1
        }
        checkpoints = checkpointsAux
        noCheckpoints = checkpoints.count
        if checkpoints.count > 2 {
            checkpoints[1].title = "Next checkpoint.yellow"
        }
        prevCheckpoint = checkpoints[0]
        nextCheckpoint = checkpoints[1]
        if checkpoints.count > 4 {
            visibleCheckpoints = [checkpoints.first!, checkpoints[1], checkpoints.last!]
        } else {
            visibleCheckpoints = checkpoints
        }
        startAR()
        isVR = true
    }
    
    func startAR() {
        arViewController.dataSource = self
        // Vertical offset by distance
        arViewController.presenter.distanceOffsetMode = .manual
        arViewController.presenter.distanceOffsetMultiplier = 0.1   // Pixels per meter
        arViewController.presenter.distanceOffsetMinThreshold = 5 // Doesn't raise annotations that are nearer than this
        // Filtering for performance
        arViewController.presenter.maxDistance = 50000               // Don't show annotations if they are farther than this
        arViewController.presenter.maxVisibleAnnotations = 5      // Max number of annotations on the screen
        // Stacking
        arViewController.presenter.verticalStackingEnabled = true
        // Location precision
        arViewController.trackingManager.userDistanceFilter = 15
        arViewController.trackingManager.reloadDistanceFilter = 50
        // Ui
        arViewController.uiOptions.closeButtonEnabled = true
        // Interface orientation
        arViewController.interfaceOrientationMask = .all
        // Setting annotations
        arViewController.setAnnotations(visibleCheckpoints)
        // Presenting controller
        
        self.present(arViewController, animated: true, completion: nil)
    }
    
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView
    {
        // Annotation views should be lightweight views, try to avoid xibs and autolayout all together.
        let checkpointView = CheckpointView()
        checkpointView.delegate = self
        checkpointView.frame = CGRect(x: 0,y: 0,width: 250,height: 50)
        return checkpointView;
    }
    
    func proceedToNextCheckpoint() {
        let index = checkpoints.index(of: nextCheckpoint!)!
        if index == checkpoints.count - 1 {
            arViewController.dismiss(animated: true, completion: nil)
            isVR = false
            let alert = UIAlertController(title: "Navigation completed",
                                          message: "You have reached your destination" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        } else {
            checkpoints[index].title = "Previous checkpoint.red"
            prevCheckpoint = nextCheckpoint!
            checkpoints[index + 1].title = "Next checkpoint.yellow"
            nextCheckpoint = checkpoints[index + 1]
            if checkpoints.count > 4 {
                if index < checkpoints.count - 2 {
                    visibleCheckpoints = [checkpoints.first!, prevCheckpoint!, nextCheckpoint!, checkpoints.last!]
                } else {
                    visibleCheckpoints = [checkpoints.first!, prevCheckpoint!, nextCheckpoint!]
                }
            } else {
                visibleCheckpoints = checkpoints
            }
            arViewController.setAnnotations(visibleCheckpoints)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !(arViewController.isViewLoaded && (arViewController.view.window != nil)) && self.isVR == true {
            self.isVR = false
        }
        if isVR {
            if locations.count > 0 {
                let location = locations.last!
                if location.horizontalAccuracy < 20 {
                    if nextCheckpoint != nil {
                        if Double(location.distance(from: checkpoints.last!.location)) < 20 {
                            arViewController.dismiss(animated: true, completion: nil)
                            isVR = false
                            let alert = UIAlertController(title: "Navigation completed",
                                                          message: "You have reached your destination" as String, preferredStyle:.alert)
                            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                            alert.addAction(done)
                            self.present(alert, animated: true, completion: nil)
                        } else if Double(location.distance(from: nextCheckpoint!.location)) < 20 {
                            let index = checkpoints.index(of: nextCheckpoint!)!
                            
                            checkpoints[index].title = "Previous checkpoint.red"
                            prevCheckpoint = nextCheckpoint!
                            checkpoints[index + 1].title = "Next checkpoint.yellow"
                            nextCheckpoint = checkpoints[index + 1]
                            if checkpoints.count > 4 {
                                if index < checkpoints.count - 2 {
                                    visibleCheckpoints = [checkpoints.first!, prevCheckpoint!, nextCheckpoint!, checkpoints.last!]
                                } else {
                                    visibleCheckpoints = [checkpoints.first!, prevCheckpoint!, nextCheckpoint!]
                                }
                            } else {
                                visibleCheckpoints = checkpoints
                            }
                            arViewController.setAnnotations(visibleCheckpoints)
                        }
                    }
                }
            }
        }
    }
    
    func openMapForPlace() {
        let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(offers[0].latitude!), longitude: CLLocationDegrees(offers[0].longitude!))
        let locationDistance: CLLocationDistance = 10000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates, locationDistance, locationDistance)
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = offers[0].name!
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinateRegion.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: coordinateRegion.span)
        ])
    }
    
    @IBAction func checkoutButtonPressed(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "type") as! String == "product" {
            
            let alert = UIAlertController(title: "Checkout",
                                          message: "Purchase this offer for \(offers[selectedCategory].discount!) GBP?" as String, preferredStyle:.alert)
            let yes = UIAlertAction(title: "Yes", style: .default, handler: {
                alert -> Void in
                self.checkoutModel.productCheckout(offerId: self.offers[self.selectedCategory].id!)
            })
            alert.addAction(yes)
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Checkout",
                                          message: "Book an appointment for \(offers[selectedCategory].discount!) GBP in between \(timeIntervals[timeIntervalPickerView.selectedRow(inComponent: 0)])?" as String, preferredStyle:.alert)
            let yes = UIAlertAction(title: "Yes", style: .default, handler: {
                alert -> Void in
                self.checkoutModel.serviceCheckout(offerId: self.offers[self.selectedCategory].id!, appointment: Utils.instance.getIndex(startingTime: self.startingTime, duration: self.duration, time: self.timeIntervals[self.timeIntervalPickerView.selectedRow(inComponent: 0)]))
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
        if UserDefaults.standard.value(forKey: "type") as! String == "location" {
            dropdownMenuButton.initMenu(["View Profile", "Sign Out"], actions: [
                ({ () -> (Void) in
                    self.performSegue(withIdentifier: "locationDetailsProfileViewController", sender: nil)
                }),
                ({ () -> (Void) in
                    self.signOut(Any.self)
                })])
        } else {
            dropdownMenuButton.initMenu(["View Profile", "View Receipts", "Sign Out"], actions: [
                ({ () -> (Void) in
                    self.performSegue(withIdentifier: "locationDetailsProfileViewController", sender: nil)
                }),
                ({ () -> (Void) in
                    if self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] is ReceiptsViewController {
                        _ = self.navigationController?.popViewController(animated: true)
                    } else {
                        self.performSegue(withIdentifier: "locationDetailsReceiptsViewController", sender: nil)
                    }
                }),
                ({ () -> (Void) in
                    self.signOut(Any.self)
                })])
        }
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
