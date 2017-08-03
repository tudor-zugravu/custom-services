//
//  Utils.swift
//  Custom-Services
//
//  Created by Tudor Zugravu on 03/08/2017.
//  Copyright © 2017 Tudor Zugravu. All rights reserved.
//

import Foundation

private let _instance = Utils()

class Utils: NSObject {
    
    fileprivate override init() {
        
    }
    
    class var instance: Utils {
        return _instance
    }

    func getTime(time: Int) -> String {
        if time < 8 {
            if time % 4 == 0 {
                return "0\(time / 4 + 8):0\((time % 4) * 15)"
            } else {
                return "0\(time / 4 + 8):\((time % 4) * 15)"
            }
        } else {
            if time % 4 == 0 {
                return "\(time / 4 + 8):0\((time % 4) * 15)"
            } else {
                return "\(time / 4 + 8):\((time % 4) * 15)"
            }
        }
    }
}
