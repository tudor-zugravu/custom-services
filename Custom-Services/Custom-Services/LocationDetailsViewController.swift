//
//  LocationDetailsViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 11/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class LocationDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, FavouriteModelProtocol, RatingModelProtocol {

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
    var locationId: Int = 0
    var rating: Int = 2
    var favourite: Bool = false
    let favouriteModel = FavouriteModel()
    let ratingModel = RatingModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favouriteModel.delegate = self
        ratingModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (UserDefaults.standard.value(forKey: "storedOffers") != nil) {
            if let data = UserDefaults.standard.data(forKey: "storedOffers"),
                let offersAux = NSKeyedUnarchiver.unarchiveObject(with: data) as? [OfferModel] {
                offers = offersAux.filter({ $0.locationId == locationId})
            }
        }
//        print(offers)
        
        titleLabel.text = offers[0].name!
        ratingLabel.text = "\(String(format: "%.1f", offers[0].rating!))"
        addressLabel.text = offers[0].address;
        timeIntervalLabel.text = "\(offers[0].minTime!) - \(offers[0].maxTime!)"
        aboutLabel.text = offers[0].about
        
        if UserDefaults.standard.bool(forKey: "hasCategories") == true {
            categories = UserDefaults.standard.value(forKey: "categories")! as! [String]
            if offers.count == 1 {
                oneCategoryDiscountLabel.text = "\(offers[0].discount!) discount"
                oneCategoryDiscountLabel.isHidden = false
                categoryStack.isHidden = true
            } else {
                categoryLabel.text = UserDefaults.standard.value(forKey: "type") as! String == "location" ? "Discount for" : "The price for"
                oneCategoryDiscountLabel.isHidden = true
                categoryStack.isHidden = false
                categoryPickerView.dataSource = self
                categoryPickerView.delegate = self
                categoryPickerView.selectRow(0, inComponent: 0, animated: false)
            }
        } else {
            oneCategoryDiscountLabel.text = "\(offers[0].discount!)"
            oneCategoryDiscountLabel.isHidden = false
            categoryStack.isHidden = true
        }
        
        if UserDefaults.standard.value(forKey: "type") as! String == "location" {
            rateLocationButton.isHidden = false
            checkoutButton.isHidden = true
        } else {
            rateLocationButton.isHidden = true
            checkoutButton.isHidden = false
        }
        
            
//            if discountRange != nil && discountRange != "" {
//                priceLabel.text = "\(discountRange!)% OFF"
//            } else {
//                if UserDefaults.standard.value(forKey: "type") as! String == "location" {
//                    priceLabel.text = "\(Int(discount))% OFF"
//                } else {
//                    priceLabel.text = "\(discount)% OFF"
//                }
//            }
//        } else {
//            if discountRange != nil && discountRange != "" {
//                priceLabel.text = "\(discountRange!) GBP"
//            } else {
//                priceLabel.text = "\(discount) GBP"
//            }
        
        //TODO: add global default photos
        logoImage.image = offers[0].offerLogo != "" ? UIImage(named: offers[0].offerLogo!) : UIImage(named: "stChristophersLogo")
        locationImage.image = offers[0].offerImage != "" ? UIImage(named: offers[0].offerImage!) : UIImage(named: "stChristophersImage")
        if (favourite == true) {
            favouriteButton.setImage(UIImage(named: "fullHeart.png"), for: UIControlState.normal)
        } else {
            favouriteButton.setImage(UIImage(named: "emptyHeart.png"), for: UIControlState.normal)
        }
//        if quantity == 0 {
//            finishedImage.image = UIImage(named: UserDefaults.standard.value(forKey: "type") as! String == "product" ? "soldOut.png" : "fullyBooked.png")
//            finishedImage.isHidden = false
//        } else {
//            finishedImage.isHidden = true
//        }
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == categoryPickerView ? offers.count : 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPickerView {
            return offers[row].category!
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPickerView {
            discountLabel.text = UserDefaults.standard.value(forKey: "type") as! String == "location" ? "\(Int(offers[row].discount!))%" : "\(offers[row].discount!) GBP"
        }
    }
    
    func favouriteSelected(_ result: NSString, tag: Int) {
        if result == "1" {
            favourite = favourite ? false : true
            favouriteButton.setImage(UIImage(named: favourite == false ? "emptyHeart.png" : "fullHeart.png"), for: UIControlState.normal)
        }
    }
    
    func ratingResponse(_ result: NSString) {
        print(result)
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

}
