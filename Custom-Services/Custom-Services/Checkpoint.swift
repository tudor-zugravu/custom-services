//
//  Checkpoint.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 14/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation
import CoreLocation
import HDAugmentedReality

class Checkpoint: ARAnnotation {
    var color: UIColor = UIColor.white
    
    init(location: CLLocation, checkpointLabel: String, color: UIColor) {
        self.color = color
        super.init(identifier: nil, title: checkpointLabel, location: location)!
    }
}
