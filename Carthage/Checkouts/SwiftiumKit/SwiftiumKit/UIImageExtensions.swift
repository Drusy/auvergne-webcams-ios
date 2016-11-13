//
//  UIImageExtensions.swift
//  SwiftiumKit
//
//  Created by Richard Bergoin on 19/10/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import UIKit

extension UIImage {
    
    /**
     Creates a copy of image where non zero alpha pixels are filled with given color
     
     Usage example:
     ````
     image.colorized(withColor: UIColor.red)
     ````
     
     - Parameter color: a UIColor
     - Returns: an UIImage instance
     */
    public func colorizedImage(withColor color: UIColor) -> UIImage? {
        var image: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        if let ctx = UIGraphicsGetCurrentContext() {
            let area = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            ctx.scaleBy(x: 1, y: -1)
            ctx.translateBy(x: 0, y: -area.size.height)
            ctx.saveGState()
            ctx.clip(to: area, mask: self.cgImage!)
            color.set()
            ctx.fill(area)
            ctx.restoreGState()
            ctx.setBlendMode(CGBlendMode.normal)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
}
