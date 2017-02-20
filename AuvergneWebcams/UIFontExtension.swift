//
//  UIFontExtension.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/10/2016.
//  Copyright © 2016 Openium. All rights reserved.
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

    static func openSansSemiBoldFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Semibold", size: size)!
    }
    
    static func openSansItalicFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Italic", size: size)!
    }
    
    static func proximaNovaSemiBold(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "ProximaNova-Semibold", size: size)!
    }
    
    static func proximaNovaSemiBoldItalic(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "ProximaNova-SemiboldIt", size: size)!
    }

    static func proximaNovaLightItalic(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "ProximaNova-LightIt", size: size)!
    }
    
    static func proximaNovaRegular(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "ProximaNova-Regular", size: size)!
    }
}
