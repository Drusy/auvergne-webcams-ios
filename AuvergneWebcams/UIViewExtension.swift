//
//  UIViewExtension.swift
//  AuvergneWebcams
//
//  Created by Drusy on 11/01/2017.
//  Copyright © 2017 AuvergneWebcams. All rights reserved.
//

import Foundation

extension UIView {
    func fit(toSubview subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false;
        let views: [String: UIView] = ["subview": subview];
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[subview]|",
                                                                 options: NSLayoutFormatOptions(rawValue: 0),
                                                                 metrics: nil,
                                                                 views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[subview]|",
                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                   metrics: nil,
                                                                   views: views)
        addConstraints(verticalConstraints)
        addConstraints(horizontalConstraints)
    }
    
    func applyRadiusAndShadow() {
        applyRadius()
        applyShadow()
    }
    
    func applyShadow(opacity: Float = 0.25,
                     radius: CGFloat = 4,
                     color: UIColor = UIColor.black,
                     offset: CGSize = CGSize(width: 1, height: 1)) {
        layoutIfNeeded()
        
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
    }
    
    func applyRadius(ratio: CGFloat = 2, andMaskToBounds maskToBounds: Bool = false) {
        layoutIfNeeded()
        layer.cornerRadius = frame.height / ratio
        
        if maskToBounds {
            layer.masksToBounds = maskToBounds
        }
    }
}
