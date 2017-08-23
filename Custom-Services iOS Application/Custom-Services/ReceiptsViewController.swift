//
//  ReceiptsViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 12/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

// The class used for providind the functionalitites of the receipts ViewControler
class ReceiptsViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ReceiptsModelProtocol, ReceiptsListCellProtocol, CheckoutRatingModelProtocol  {
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    var receipts: [ReceiptModel] = []
    var filteredReceipts: [ReceiptModel] = []
    var searchOn : Bool = false
    var receiptsModel = ReceiptsModel()
    var checkoutRatingModel = CheckoutRatingModel()
    var refreshControl: UIRefreshControl!
    
    // Function called upon the completion of the loading
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        receiptsModel.delegate = self
        checkoutRatingModel.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to reload offers")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    // Function called upon the completion of the view's rendering
    override func viewWillAppear(_ animated: Bool) {
        searchOn = false
        searchBar.text = ""
        customizeAppearance()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        refreshTable()
    }
    
    // Function called when the view is about to disappear
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Function that performs the customisation of the visual elements
    func customizeAppearance() {
        navigationView.backgroundColor = Utils.instance.mainColour
        mainView.backgroundColor = Utils.instance.backgroundColour
        bottomView.backgroundColor = Utils.instance.mainColour
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchOn = (searchBar.text != nil && searchBar.text != "") ? true : false
        filteredReceipts = receipts.filter({ (receipt) -> Bool in
            return receipt.name!.lowercased().range(of: searchText.lowercased()) != nil;
        })
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchOn = (searchBar.text != nil && searchBar.text != "") ? true : false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchOn = (searchBar.text != nil && searchBar.text != "") ? true : false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchOn = true
            searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchOn = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return searchOn ? filteredReceipts.count : receipts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "receiptsCell") as? ReceiptsTableViewCell else {
            return ReceiptsTableViewCell()
        }
        cell.tag = indexPath.row
        cell.delegate = self
        
        let item: ReceiptModel = searchOn ? filteredReceipts[indexPath.row] : receipts[indexPath.row]
        cell.configureCell(item.name!, discount: item.discount!, timeInterval: item.timeInterval!, offerLogo: item.offerLogo!, redeemed: item.redeemed!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var title = ""
        switch receipts[indexPath.row].redeemed! {
        case 0:
            title = "Redeem offer"
            break
        case 1:
            title = "Offer redeemed"
            break
        default:
            title = "Receipt expired"
            break
        }
        let redeem = UITableViewRowAction(style: .normal, title: title) { action, index in
            if self.receipts[indexPath.row].redeemed! == 0 {
                let alert = UIAlertController(title: "Redeem offer",
                                              message: "The receipt is valid only if redeemed by the vendor. Please present the phone to the vendor. Proceed?" as String, preferredStyle:.alert)
                let yes = UIAlertAction(title: "Yes", style: .default, handler: {
                    alert -> Void in
                    self.receiptsModel.redeem(receiptId: self.receipts[indexPath.row].id!, row: indexPath.row)
                })
                alert.addAction(yes)
                let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        }
        redeem.backgroundColor = receipts[indexPath.row].redeemed! > 0 ? UIColor(red: 235 / 255.0, green: 46 / 255.0, blue: 32 / 255.0, alpha: 1) : UIColor(red: 16 / 255.0, green: 173 / 255.0, blue: 203 / 255.0, alpha: 1)
        
        return [redeem]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationDetailsViewController = (self.storyboard?.instantiateViewController(withIdentifier: "locationDetailsViewController"))! as! LocationDetailsViewController
        locationDetailsViewController.locationId = receipts[indexPath.row].locationId!
        locationDetailsViewController.favourite = receipts[indexPath.row].favourite!
        self.navigationController?.pushViewController(locationDetailsViewController , animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didPressRatingButton(_ tag: Int) {
        let ratingPopUp = UIAlertController(title: "Rate offer",
                                              message: "How would you rate your experience on a scale from 1 to 5?" as String, preferredStyle:.alert)
        ratingPopUp.addTextField { (ratingTextField: UITextField!) -> Void in
            ratingTextField.keyboardType = .numberPad
            ratingTextField.placeholder = ""
        }
        let rate = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let ratingTextField = ratingPopUp.textFields![0] as UITextField
            if ratingTextField.text != nil && ratingTextField.text != "" && Int(ratingTextField.text!) != nil {
                if Int(ratingTextField.text!)! >= 1 && Int(ratingTextField.text!)! <= 5 {
                    self.checkoutRatingModel.sendRating(receiptId: self.receipts[tag].id!, locationId: self.receipts[tag].locationId!, rating: Int(ratingTextField.text!)!)
                } else {
                    let alert = UIAlertController(title: "Error",
                                                  message: "Please enter a valid digit" as String, preferredStyle:.alert)
                    let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Error",
                                              message: "Please enter a valid digit" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        })
        
        ratingPopUp.addAction(rate)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        ratingPopUp.addAction(cancel)
        self.present(ratingPopUp, animated: true, completion: nil)
    }
    
    func ratingResponse(_ result: [String:Any]) {
        if let status = result["status"] as? String {
            if status == "success" {
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
        } else {
            let alert = UIAlertController(title: "Error",
                                          message: "Please try again" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func redeemStatus(_ result: [String:Any], row: Int) {
        if let status = result["status"] as? String {
            if status == "success" {
                refreshTable()
                let alert = UIAlertController(title: "Offer redeemed",
                                              message: "" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error",
                                              message: "There has been a problem with your receipt" as String, preferredStyle:.alert)
                let done = UIAlertAction(title: "Done", style: .default, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Error",
                                          message: "There has been a problem with your receipt" as String, preferredStyle:.alert)
            let done = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func receiptsReceived(_ receipts: [[String:Any]]) {
        
        let delayedTime = Calendar.current.date(byAdding: .minute, value: -30, to: Date())
        let year = Calendar.current.component(.year, from: delayedTime!)
        let month = Calendar.current.component(.month, from: delayedTime!) < 10 ? "0\(Calendar.current.component(.month, from: delayedTime!))" : "\(Calendar.current.component(.month, from: delayedTime!))"
        let day = Calendar.current.component(.day, from: delayedTime!) < 10 ? "0\(Calendar.current.component(.day, from: delayedTime!))" : "\(Calendar.current.component(.day, from: delayedTime!))"
        let hour = Calendar.current.component(.hour, from: delayedTime!) < 10 ? "0\(Calendar.current.component(.hour, from: delayedTime!))" : "\(Calendar.current.component(.hour, from: delayedTime!))"
        let minute = Calendar.current.component(.minute, from: delayedTime!) < 10 ? "0\(Calendar.current.component(.minute, from: delayedTime!))" : "\(Calendar.current.component(.minute, from: delayedTime!))"
        
        let currentDate = "\(year)-\(month)-\(day)"
        let currentTime = "\(hour):\(minute)"

        var receiptsAux: [ReceiptModel] = []
        var item:ReceiptModel;
        // parse the received JSON and save the contacts
        for i in 0 ..< receipts.count {

            if let receiptId = Int((receipts[i]["receipt_id"] as? String)!),
                let locationId = Int((receipts[i]["location_id"] as? String)!),
                let offerId = Int((receipts[i]["offer_id"] as? String)!),
                let name = receipts[i]["name"] as? String,
                let discount = Float((receipts[i]["discount"] as? String)!),
                let startingTime = receipts[i]["starting_time"] as? String,
                let endingTime = receipts[i]["ending_time"] as? String,
                let purchaseDate = receipts[i]["purchase_date"] as? String,
                let redeemed = Int((receipts[i]["redeemed"] as? String)!)
            {
                item = ReceiptModel()
                item.id = receiptId
                item.locationId = locationId
                item.offerId = offerId
                item.name = name
                item.discount = discount
                item.redeemed = redeemed
                
                if let favourite = receipts[i]["favourite"] as? String {
                    item.favourite = favourite == "1" ? true : false
                } else {
                    item.favourite = false
                }
                
                let timeInterval = purchaseDate.components(separatedBy: " ")[0]
                
                if UserDefaults.standard.value(forKey: "type") as! String == "product" {
                    item.timeInterval = "\(timeInterval) \(Utils.instance.trimSeconds(time: startingTime)) - \(Utils.instance.trimSeconds(time: endingTime))"
                    if currentDate <= timeInterval {
                        if endingTime < currentTime {
                            item.redeemed = item.redeemed == 1 ? 1 : 2
                        }
                    } else {
                        item.redeemed = item.redeemed == 1 ? 1 : 2
                    }
                } else {
                    if let appointment = Int((receipts[i]["appointment_starting"] as? String)!),
                        let duration = Int((receipts[i]["appointment_minute_duration"] as? String)!){
                        item.timeInterval = "\(timeInterval) \(Utils.instance.getTimeInterval(startingTime: startingTime, duration: duration, appointment: appointment))"
                        let timeComponents = item.timeInterval?.components(separatedBy: " ")
                        if currentDate <= timeInterval {
                            if (timeComponents?[1])! < currentTime {
                                item.redeemed = item.redeemed == 1 ? 1 : 2
                            }
                        } else {
                            item.redeemed = item.redeemed == 1 ? 1 : 2
                        }
                    } else {
                        item.timeInterval = "\(timeInterval) \(Utils.instance.trimSeconds(time: startingTime)) - \(Utils.instance.trimSeconds(time: endingTime))"
                        if currentDate <= timeInterval {
                            if endingTime < currentTime {
                                item.redeemed = item.redeemed == 1 ? 1 : 2
                            }
                        } else {
                            item.redeemed = item.redeemed == 1 ? 1 : 2
                        }
                    }
                }
                
                if let logoImage = receipts[i]["logo_image"] as? String {
                    
                    let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(logoImage)")
                    if FileManager.default.fileExists(atPath: filename.path) {
                        item.offerLogo = logoImage
                    } else {
                        // Download the profile picture, if exists
                        if let url = URL(string: "\(Utils.serverAddress)/resources/vendor_images/\(logoImage)") {
                            if let data = try? Data(contentsOf: url) {
                                var logoImg: UIImage
                                logoImg = UIImage(data: data)!
                                if let data = UIImagePNGRepresentation(logoImg) {
                                    try? data.write(to: filename)
                                    item.offerLogo = logoImage
                                } else {
                                    item.offerLogo = ""
                                }
                            } else {
                                item.offerLogo = ""
                            }
                        }
                    }
                } else {
                    item.offerLogo = ""
                }
                
                receiptsAux.append(item)
            }
        }
        self.receipts = receiptsAux.sorted(by: { (receipt1, receipt2) -> Bool in
            if receipt1.id! > receipt2.id! {
                return true
            }
            return false
        })
        
        let storedReceipts = NSKeyedArchiver.archivedData(withRootObject: self.receipts)
        UserDefaults.standard.set(storedReceipts, forKey:"storedReceipts");
        
        tableView.reloadData()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func refreshTable() {
        receiptsModel.requestReceipts()
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
            
            self.bottomConstraint.constant = (keyboardFrame.height  - 50) * (show ? 1 : 0)
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        tableView.reloadData()
    }
    
    // Called to dismiss the keyboard from the screen
    func dismissKeyboard(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }
}

