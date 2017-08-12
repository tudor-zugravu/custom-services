//
//  ReceiptsTableViewCell.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 12/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class ReceiptsTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var offerLogoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var availableView: UIView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //cell layout
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOffset = CGSize(width:-2, height:2)
        containerView.layer.shadowRadius = 3
        containerView.layer.shadowOpacity = 0.6
        containerView.layer.masksToBounds = false
        containerView.clipsToBounds = false
        availableView.layer.borderWidth = 1
        availableView.layer.borderColor = UIColor.lightGray.cgColor
        availableView.layer.masksToBounds = false
        availableView.clipsToBounds = false
    }
    
    func configureCell(_ name: String, discount: Float, timeInterval: String, offerLogo: String, redeemed: Int) {
        titleLabel.text = name
        timeIntervalLabel.text = timeInterval
        offerLogoImage.image = offerLogo != "" ? UIImage(named: offerLogo) : UIImage(named: "stChristophersLogo")
        if UserDefaults.standard.value(forKey: "type") as! String == "location" {
            discountLabel.text = "\(Int(discount))% OFF"
        } else {
            discountLabel.text = "\(discount) GBP"
        }
        
        // TODO customize
        if redeemed > 0 {
            starButton.isEnabled = true
            starButton.alpha = 1
            rateButton.isEnabled = true
            rateButton.alpha = 1
        } else {
            starButton.isEnabled = false
            starButton.alpha = 0.5
            rateButton.isEnabled = false
            rateButton.alpha = 0.5
        }        
    }

    @IBAction func rateLocationPressed(_ sender: Any) {
        print("RATE")
    }
}
