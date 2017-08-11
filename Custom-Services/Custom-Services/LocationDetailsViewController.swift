//
//  LocationDetailsViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 11/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class LocationDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

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
    @IBOutlet weak var checkoutButton: UIButton!
    
    var offers: [OfferModel] = []
    var categories: [String] = []
    var locationId: Int = 0
    var favourite: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationImage.layer.cornerRadius = 10
        locationImage.layer.borderWidth = 1
        locationImage.layer.borderColor = UIColor.lightGray.cgColor
        locationImage.clipsToBounds = true
        
        if (UserDefaults.standard.value(forKey: "storedOffers") != nil) {
            if let data = UserDefaults.standard.data(forKey: "storedOffers"),
                let offersAux = NSKeyedUnarchiver.unarchiveObject(with: data) as? [OfferModel] {
                offers = offersAux.filter({ $0.locationId == locationId})
            }
        }
        print(offers)
        
        titleLabel.text = offers[0].name!
        ratingLabel.text = "\(String(format: "%.1f", offers[0].rating!))"
        addressLabel.text = offers[0].address;
        timeIntervalLabel.text = "\(offers[0].minTime!) - \(offers[0].maxTime!)"
        aboutLabel.text = offers[0].about
        
        if UserDefaults.standard.bool(forKey: "hasCategories") == true {
            categories = UserDefaults.standard.value(forKey: "categories")! as! [String]
            if offers.count == 1 {
                oneCategoryDiscountLabel.text = "\(offers[0].discount!)"
                oneCategoryDiscountLabel.isHidden = false
                categoryStack.isHidden = true
            } else {
                categoryLabel.text = UserDefaults.standard.value(forKey: "type") as! String == "location" ? "Discount for" : "The price for"
                oneCategoryDiscountLabel.isHidden = true
                categoryStack.isHidden = false
                categoryPickerView.dataSource = self
                categoryPickerView.delegate = self
            }
        } else {
            oneCategoryDiscountLabel.text = "\(offers[0].discount!)"
            oneCategoryDiscountLabel.isHidden = false
            categoryStack.isHidden = true
        }
        
        if UserDefaults.standard.value(forKey: "type") as! String == "location" {
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
        }
        
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
    
    @IBAction func getDirectionsButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func checkoutButtonPressed(_ sender: Any) {
        
    }

    @IBAction func favouriteButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }

}
