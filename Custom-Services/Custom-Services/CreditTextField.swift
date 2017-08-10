//
//  CreditTextField.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 09/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation
import UIKit

class CreditTextField: UITextField {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }

}
