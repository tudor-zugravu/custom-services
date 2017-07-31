//
//  ViewController.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 31/07/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var michaelImage: UIImageView!
    @IBOutlet weak var getSchwiftyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func getSchwifty(_ sender: Any) {
        if michaelImage.isHidden {
            michaelImage.isHidden = false
            getSchwiftyButton.isHidden = true
        } else {
            michaelImage.isHidden = true
            getSchwiftyButton.isHidden = false
        }
    }

}

