//
//  NavigationController.swift
//  UPA
//
//  Created by Drusy on 07/05/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class NavigationController: UINavigationController {
    
    fileprivate var shadowImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        style()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationBar)
        }
        shadowImageView?.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        shadowImageView?.isHidden = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: -
    
    func style() {
        let color = UIColor.white

        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.foregroundColor: color,
            NSAttributedStringKey.font: UIFont.proximaNovaSemiBold(withSize: 17)
        ]

        navigationBar.titleTextAttributes = attributes
        navigationBar.tintColor = color
        navigationBar.isTranslucent = true
        navigationBar.barStyle = .black

        UINavigationBar.appearance().titleTextAttributes = attributes
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)

        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func update() {
        if self.topViewController != nil && self.topViewController!.responds(to: #selector(update)) {
            _ = topViewController?.perform(#selector(update))
        }
    }
    
    // MARK: - 
    
    fileprivate func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }

        for subview in view.subviews {
            if let imageView = findShadowImage(under: subview) {
                return imageView
            }
        }

        return nil
    }
}
