//
//  UIColor+OSKAdditions.swift
//  OpeniumSwiftKit
//
//  Created by Richard Bergoin on 21/07/15.
//  Copyright (c) 2015 Openium. All rights reserved.
//

import UIKit

extension UIColor {
    
    /**
     Method to instanciate a color from an int (0xRRGGBB)
     
     Usage example :
     ````
     color = UIColor(rgb: 0xAABBCC)
     ````
     
     - Parameter rgb: an int which bytes represents red, green and blue components.
     - Returns: an UIColor instance
     */
    public convenience init(rgb: Int64) {
        let alpha = CGFloat(1.0)
        let red   = CGFloat((0xff0000   & rgb) >> 16) / 255.0
        let green = CGFloat((0xff00     & rgb) >>  8) / 255.0
        let blue  = CGFloat((0xff       & rgb)      ) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     Method to instanciate a color from an int (0xRRGGBBAA).
     
     Usage example :
     ````
     color = UIColor(rgb: 0xAABBCCDD)
     ````
     
     - Parameter rgba: an int which bytes represents red, green blue and alpha components
     - Returns: an UIColor instance
     */
    public convenience init(rgba: Int64) {
        let red   = CGFloat((0xff000000 & rgba) >> 24) / 255.0
        let green = CGFloat((0xff0000   & rgba) >> 16) / 255.0
        let blue  = CGFloat((0xff00     & rgba) >>  8) / 255.0
        let alpha = CGFloat((0xff       & rgba)      ) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     Method to instanciate a color from an int (0xAARRGGBB).
     
     Usage example :
     ````
     color = UIColor(rgb: 0xAABBCCDD)
     ````
     
     - Parameter argb: an int which bytes represents alpha, red, green and blue components
     - Returns: an UIColor instance
     */
    public convenience init(argb: Int64) {
        let alpha = CGFloat((0xff000000 & argb) >> 24) / 255.0
        let red   = CGFloat((0xff0000   & argb) >> 16) / 255.0
        let green = CGFloat((0xff00     & argb) >>  8) / 255.0
        let blue  = CGFloat((0xff       & argb)      ) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     Creates an image of `size` filled with current color
     
     Usage example:
     ````
     UIColor.red.image(withSize: CGSize(width: 10, height: 10))
     ````
     
     - Parameter size: a CGSize
     - Returns: an UIImage instance
     */
    public func image(withSize size: CGSize) -> UIImage? {
        var image: UIImage? = nil
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(cgColor)
            context.fill(rect)
            
            image = UIGraphicsGetImageFromCurrentImageContext()   
        }
        UIGraphicsEndImageContext()
        return image
    }

}
