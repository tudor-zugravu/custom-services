//
//  CheckpointView.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 14/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import UIKit
import HDAugmentedReality

open class CheckpointView: ARAnnotationView, UIGestureRecognizerDelegate
{
    open var titleLabel: UILabel?
    
    override open func initialize()
    {
        super.initialize()
        self.loadUi()
    }
    
    func loadUi()
    {
        // Title label
        self.titleLabel?.removeFromSuperview()
        let label = UILabel()
        label.font = UIFont(name: "Futura-Medium", size: 17 )
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        self.addSubview(label)
        self.titleLabel = label
        
        self.backgroundColor = UIColor(red: 16 / 255.0, green: 173 / 255.0, blue: 203 / 255.0, alpha: 1)        
        self.layer.cornerRadius = 10
        
        if self.annotation != nil
        {
            self.bindUi()
        }
    }
    
    func layoutUi()
    {
        let buttonWidth: CGFloat = 40
        self.titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width - buttonWidth - 5, height: self.frame.size.height);
    }
    
    // This method is called whenever distance/azimuth is set
    override open func bindUi()
    {
        if let annotation = self.annotation, let title = annotation.title
        {
            let distance = annotation.distanceFromUser > 1000 ? String(format: "%.1fkm", annotation.distanceFromUser / 1000) : String(format:"%.0fm", annotation.distanceFromUser)
            
            let text = String(format: "%@\ndistance: %@", title, distance)
            self.titleLabel?.text = text
        }
    }
    
    open override func layoutSubviews()
    {
        super.layoutSubviews()
        self.layoutUi()
    }
}
