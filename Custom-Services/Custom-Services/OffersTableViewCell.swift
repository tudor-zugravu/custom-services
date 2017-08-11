//
//  ListTableViewCell.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 01/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

protocol OfferListCellProtocol : class {
    func didPressFavouriteButton(_ tag: Int)
}

class OffersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var offerLogo: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var finishedImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var opaqueView: UIView!
    
    weak var delegate: OfferListCellProtocol?
    var isFavourite: Bool = true
    
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
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = opaqueView.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if(selected) {
            opaqueView.backgroundColor = color
        }
    }
    
    @IBAction func favouriteButtonPressed(_ sender: Any) {
        if (isFavourite == false) {
            isFavourite = true
            favouriteButton.setImage(UIImage(named: "fullHeart.png"), for: UIControlState.normal)
        } else {
            isFavourite = false
            favouriteButton.setImage(UIImage(named: "emptyHeart.png"), for: UIControlState.normal)
        }
        delegate?.didPressFavouriteButton(self.tag)
    }
    
    func configureCell(_ name: String, rating: Float, distance: Int, discount: Int, minTime: String, maxTime: String, offerImage: String, offerLogo: String, favourite: Bool, quantity: Int, discountRange: String?) {
        
        nameLabel.text = name
        ratingLabel.text = "\(String(format: "%.1f", rating))"
        let dist: String = distance < 1200 ? "\(distance) m" : "\(String(format: "%.1f", Float(distance)/1000)) km"
        distanceLabel.text = dist
        if UserDefaults.standard.value(forKey: "type") as! String == "location" {
            if discountRange != nil && discountRange != "" {
                priceLabel.text = "\(discountRange!)% OFF"
            } else {
                priceLabel.text = "\(discount)% OFF"
            }
        } else {
            if discountRange != nil && discountRange != "" {
                priceLabel.text = "\(discountRange!)% GBP"
            } else {
                priceLabel.text = "\(discount)% GBP"
            }
        }
        timeLabel.text = "\(minTime) - \(maxTime)"
        
        //TODO: add global default photos
        self.offerImage.image = offerImage != "" ? UIImage(named: offerImage) : UIImage(named: "stChristophersImage")
        self.offerLogo.image = offerLogo != "" ? UIImage(named: offerLogo) : UIImage(named: "stChristophersLogo")
        if (favourite == true) {
            isFavourite = true
            favouriteButton.setImage(UIImage(named: "fullHeart.png"), for: UIControlState.normal)
        } else {
            isFavourite = false
            favouriteButton.setImage(UIImage(named: "emptyHeart.png"), for: UIControlState.normal)
        }
        if quantity == 0 {
            finishedImage.image = UIImage(named: "soldOut.png")
            finishedImage.isHidden = false
        } else {
            finishedImage.isHidden = true
        }
    }
}
