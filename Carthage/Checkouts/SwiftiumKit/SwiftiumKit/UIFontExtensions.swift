//
//  UIFontExtensions.swift
//  SwiftiumKit
//
//  Created by Richard Bergoin on 19/10/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import UIKit

extension UIFont {
    /**
     Method to print all font names of all families
     */
    public static func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }
    
    /**
     Method to get font names 'near' a given name.
     
     Near algorithm removes '_', ' ' (space), '-' characters from `fontName` for searching available fonts, if a font contains this searched name, it is added to the result array
     
     Usage example :
     ````
     let findedFonts = UIFont.findFont(havingNameLike: "Helvetica Bold")
     // findedFonts equals ["Helvetica-Bold"]
     ````
     
     - Parameter fontName: string for font to search
     - Returns: an array of string of found font names
     */
    public static func findFont(havingNameLike fontName: String) -> [String] {
        var maybeFontNames = [String]()
        var searchedFontName = fontName.lowercased()
        searchedFontName = searchedFontName.replacingOccurrences(of: " ", with: "")
        searchedFontName = searchedFontName.replacingOccurrences(of: "_", with: "")
        searchedFontName = searchedFontName.replacingOccurrences(of: "-", with: "")
        
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            let names = UIFont.fontNames(forFamilyName: familyName)
            for fontName in names {
                var simplifiedFontName = fontName.lowercased()
                simplifiedFontName = simplifiedFontName.replacingOccurrences(of: " ", with: "")
                simplifiedFontName = simplifiedFontName.replacingOccurrences(of: "_", with: "")
                simplifiedFontName = simplifiedFontName.replacingOccurrences(of: "-", with: "")
                if simplifiedFontName.contains(searchedFontName) {
                    maybeFontNames.append(fontName)
                }
            }
        }
        return maybeFontNames
    }
}
