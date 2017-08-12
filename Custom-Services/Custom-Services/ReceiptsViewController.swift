//
//  ReceiptsViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 12/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class ReceiptsViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ReceiptsModelProtocol  {
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var receipts: [ReceiptModel] = []
    var filteredReceipts: [ReceiptModel] = []
    var searchOn : Bool = false
    var receiptsModel = ReceiptsModel()
    var refreshControl: UIRefreshControl!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        receiptsModel.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to reload offers")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchOn = false
        searchBar.text = ""
        
        // Adding the gesture recognizer that will dismiss the keyboard on an exterior tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // COPIED
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        refreshTable()
    }
    
    // COPIED
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        
        let item: ReceiptModel = searchOn ? filteredReceipts[indexPath.row] : receipts[indexPath.row]
        cell.configureCell(item.name!, discount: item.discount!, timeInterval: item.timeInterval!, offerLogo: item.offerLogo!, redeemed: item.redeemed!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let receiptCell = cell as! ReceiptsTableViewCell
        receiptCell.availableView.backgroundColor = receipts[indexPath.row].redeemed! > 0 ? UIColor(red: 235 / 255.0, green: 46 / 255.0, blue: 32 / 255.0, alpha: 1) : UIColor(red: 16 / 255.0, green: 173 / 255.0, blue: 203 / 255.0, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let redeem = UITableViewRowAction(style: .normal, title: "Redeem offer") { action, index in
            print("redeem")
        }
        redeem.backgroundColor = receipts[indexPath.row].redeemed! > 0 ? UIColor(red: 235 / 255.0, green: 46 / 255.0, blue: 32 / 255.0, alpha: 1) : UIColor(red: 16 / 255.0, green: 173 / 255.0, blue: 203 / 255.0, alpha: 1)
        
        return [redeem]
    }
    
    func receiptsReceived(_ receipts: [[String:Any]]) {
        
        var receiptsAux: [ReceiptModel] = []
        var item:ReceiptModel;
        
        // parse the received JSON and save the contacts
        for i in 0 ..< receipts.count {
            print(receipts)
            if let receiptId = Int((receipts[i]["receipt_id"] as? String)!),
                let offerId = Int((receipts[i]["offer_id"] as? String)!),
                let name = receipts[i]["name"] as? String,
                let discount = Float((receipts[i]["discount"] as? String)!),
                let startingTime = receipts[i]["starting_time"] as? String,
                let endingTime = receipts[i]["ending_time"] as? String,
                let redeemed = Int((receipts[i]["redeemed"] as? String)!)
            {
                item = ReceiptModel()
                item.id = receiptId
                item.offerId = offerId
                item.name = name
                item.discount = discount
                item.redeemed = redeemed
                
                if UserDefaults.standard.value(forKey: "type") as! String == "product" {
                    item.timeInterval = "\(Utils.instance.trimSeconds(time: startingTime)) - \(Utils.instance.trimSeconds(time: endingTime))"
                } else {
                    if let appointment = Int((receipts[i]["appointment_starting"] as? String)!),
                        let duration = Int((receipts[i]["appointment_minute_duration"] as? String)!){
                        item.timeInterval = Utils.instance.getTimeInterval(startingTime: startingTime, duration: duration, appointment: appointment)
                    } else {
                        item.timeInterval = "\(Utils.instance.trimSeconds(time: startingTime)) - \(Utils.instance.trimSeconds(time: endingTime))"
                    }
                }
                
                if let logoImage = receipts[i]["logo_image"] as? String {
                    
                    let filename = Utils.instance.getDocumentsDirectory().appendingPathComponent("\(logoImage)")
                    if FileManager.default.fileExists(atPath: filename.path) {
                        item.offerLogo = logoImage
                    } else {
                        // Download the profile picture, if exists
                        if let url = URL(string: "http://46.101.29.197/vendor_images/\(logoImage)") {
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
        self.receipts = receiptsAux
        
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

