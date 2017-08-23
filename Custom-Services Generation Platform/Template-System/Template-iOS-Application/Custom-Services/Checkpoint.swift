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
    var color = "yellow"
    
    init(location: CLLocation, checkpointLabel: String, color: String) {
        self.color = color
        super.init(identifier: nil, title: "\(checkpointLabel).\(color)", location: location)!
    }
}
