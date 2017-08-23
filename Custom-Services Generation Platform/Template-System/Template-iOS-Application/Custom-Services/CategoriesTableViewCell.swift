//
//  CategoriesTableViewCell.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 03/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

protocol CategoriesListCellProtocol : class {
    func didSwitch(_ tag: Int)
}

class CategoriesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categorySwitch: UISwitch!
    
    weak var delegate: CategoriesListCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func categorySwitchChanged(_ sender: Any) {
        delegate?.didSwitch(self.tag)
    }
    
    func configureCell(_ category: String) {
        categoryLabel.text = category
    }
}
