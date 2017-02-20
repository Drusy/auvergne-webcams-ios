//
//  UIImageViewExtension.swift
//  MichelinDDI
//
//  Created by Drusy on 08/10/2016.
//  Copyright © 2016 Michelin. All rights reserved.
//

import UIKit

extension UIImage {
    func maskWithColor(_ color: UIColor) -> UIImage? {
        
        let maskImage = self.cgImage
        let width = self.size.width
        let height = self.size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let bitmapContext = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) //needs rawValue of bitmapInfo
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        bitmapContext?.clip(to: bounds, mask: maskImage!)
        bitmapContext?.setFillColor(color.cgColor)
        bitmapContext?.fill(bounds)
        let cImage = bitmapContext?.makeImage()
        UIGraphicsEndImageContext();

        if cImage != nil {            
            return UIImage(cgImage: cImage!)
        } else {
            return nil
        }
    }
    
    func applyGradientColors(_ gradientColors: [UIColor], blendMode: CGBlendMode = CGBlendMode.normal) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()
//        CGContextTranslateCTM(context, 0, size.height)
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -size.height)
        context?.setBlendMode(blendMode)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.draw(self.cgImage!, in: rect)
        
        // Create gradient
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = gradientColors.map { (color: UIColor) -> Any! in return color.cgColor as Any! } as NSArray
        let locs: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locs)
        
        // Apply gradient
        context?.clip(to: rect, mask: self.cgImage!)
        context?.drawLinearGradient(gradient!,
            start: CGPoint(x: 0, y: size.height),
            end: CGPoint(x: size.width, y: size.height),
            options: CGGradientDrawingOptions(rawValue: 0)
        )
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return image!;
    }
}
