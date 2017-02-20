//
//  UITableViewCellExtension.swift
//  AuvergneWebcams
//
//  Created by Drusy on 15/11/2016.
//
//

import UIKit

extension UITableViewCell {
    func prepareDisclosureIndicator() {
        for case let button as UIButton in subviews {
            let image = button.backgroundImage(for: .normal)?.withRenderingMode(.alwaysTemplate)
            button.tintColor = UIColor.white
            button.setBackgroundImage(image, for: .normal)
        }
    }
}
