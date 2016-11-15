//
//  ThemeUtils.swift
//  AuvergneWebcams
//
//  Created by Drusy on 15/11/2016.
//
//

import UIKit
import SwiftyUserDefaults
import SwiftiumKit

class ThemeUtils {
    static func tintColor() -> UIColor {
        if Defaults[.isDarkTheme] {
//            return UIColor.lightGray
            return UIColor(rgb: 0xE6E6E5)
        } else {
            return UIColor.darkGray
        }
    }
    
    static func backgroundColor() -> UIColor {
        if Defaults[.isDarkTheme] {
            return UIColor(rgb: 0x282828)
        } else {
            return UIColor(rgb: 0xFFFFFF)
        }
    }
}
