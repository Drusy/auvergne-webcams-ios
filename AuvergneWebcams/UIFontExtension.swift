//
//  UIFontExtension.swift
//  MichelinDDI
//
//  Created by Drusy on 09/10/2016.
//  Copyright © 2016 Michelin. All rights reserved.
//

import UIKit

extension UIFont {
    static func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            NSLog("------------------------------")
            NSLog("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            NSLog("Font Names = [\(names)]")
        }
    }
    
    static func openSansMediumFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Medium", size: size)!
    }
    
    static func openSansCondensedFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-CondensedBold", size: size)!
    }
}
