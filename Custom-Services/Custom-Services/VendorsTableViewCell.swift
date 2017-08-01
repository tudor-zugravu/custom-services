//
//  ListTableViewCell.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 01/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class VendorsTableViewCell: UITableViewCell {
        
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var vendorPicture: UIImageView!
    @IBOutlet weak var vendorLogo: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //cell layout
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOffset = CGSize(width:-2, height:2)
        containerView.layer.shadowRadius = 3
        containerView.layer.shadowOpacity = 0.6
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
//        containerView.clipsToBounds = false
    }
    
    func configureCell(_ name: String, rating: String, distance: String, price: String, time: String, vendorPicture: String, vendorLogo: String, favourite: Bool) {
        
        nameLabel.text = name
        ratingLabel.text = rating
        distanceLabel.text = distance
        priceLabel.text = price
        timeLabel.text = time
        if (vendorPicture != "") {
            self.vendorPicture.image = UIImage(named: vendorPicture)
        } else {
            self.vendorPicture.image = UIImage(named: "stChristophersImage")
        }
        if (vendorLogo != "") {
            self.vendorLogo.image = UIImage(named: vendorLogo)
        } else {
            self.vendorLogo.image = UIImage(named: "stChristophersLogo")
        }
        if (favourite == true) {
            favouriteButton.setImage(UIImage(named: "fullHeart.png"), for: UIControlState.normal)
        } else {
            favouriteButton.setImage(UIImage(named: "emptyHeart.png"), for: UIControlState.normal)
        }
    }
    
}
