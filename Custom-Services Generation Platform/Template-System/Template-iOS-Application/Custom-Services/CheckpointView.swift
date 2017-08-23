//
//  CheckpointView.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 14/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import HDAugmentedReality

// Protocol used for delegating touches to the class that implements it
protocol CheckpointViewDelegate {
    func proceedToNextCheckpoint()
}

// The class used for the presentation of checkpoint objects
// Implementation based on the steps provided in: https://github.com/DanijelHuis/HDAugmentedReality
open class CheckpointView: ARAnnotationView, UIGestureRecognizerDelegate, UIAlertViewDelegate {
    open var titleLabel: UILabel?
    open var infoButton: UIButton?
    var delegate: CheckpointViewDelegate?
    var color = ""
    
    override open func initialize() {
        super.initialize()
        self.loadUi()
    }
    
    func loadUi() {
        self.titleLabel?.removeFromSuperview()
        let label = UILabel()
        label.font = UIFont(name: "Futura-Medium", size: 17 )
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        self.addSubview(label)
        self.titleLabel = label
        self.infoButton?.removeFromSuperview()
        let button = UIButton(type: UIButtonType.contactAdd)
        button.isUserInteractionEnabled = false
        self.addSubview(button)
        self.infoButton = button
        self.backgroundColor = UIColor(red: 16 / 255.0, green: 173 / 255.0, blue: 203 / 255.0, alpha: 1)        
        self.layer.cornerRadius = 10
        if self.annotation != nil {
            self.bindUi()
        }
    }
    
    func layoutUi() {
        let buttonWidth: CGFloat = 40
        let buttonHeight: CGFloat = 40
        self.titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width - buttonWidth - 5, height: self.frame.size.height);
        self.infoButton?.frame = CGRect(x: self.frame.size.width - buttonWidth, y: self.frame.size.height/2 - buttonHeight/2, width: buttonWidth, height: buttonHeight);
    }
    
    // This method is called whenever distance/azimuth is set
    override open func bindUi() {
        if let annotation = self.annotation, let title = annotation.title
        {
            let components = title.components(separatedBy: ".")
            let distance = annotation.distanceFromUser > 1000 ? String(format: "%.1fkm", annotation.distanceFromUser / 1000) : String(format:"%.0fm", annotation.distanceFromUser)
            let text = String(format: "%@\ndistance: %@", components[0], distance)
            self.titleLabel?.text = text
            switch components[1] {
                case "red":
                    self.backgroundColor = UIColor(red: 235 / 255.0, green: 46 / 255.0, blue: 32 / 255.0, alpha: 1)
                    self.infoButton?.isHidden = true
                    break
                case "yellow":
                    self.backgroundColor = UIColor(red: 229 / 255.0, green: 242 / 255.0, blue: 0, alpha: 1)
                    self.infoButton?.isHidden = false
                    break
                default:
                    self.backgroundColor = UIColor(red: 47 / 255.0, green: 208 / 255.0, blue: 102 / 255.0, alpha: 1)
                    self.infoButton?.isHidden = true
                    break
            }
            self.color = components[1]
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutUi()
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let annotation = self.annotation {
            if self.color == "yellow" {
                let alertView = UIAlertView(title: (annotation.title?.components(separatedBy: ".")[0])!, message: "Proceed to the next checkpoint?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Yes")
                alertView.show()
            }
        }
    }
    
    public func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            self.delegate?.proceedToNextCheckpoint()
        }
    }
}
