
//
//  AbstractViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit

class AbstractViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(style),
                                               name: NSNotification.Name(rawValue: SettingsViewController.kSettingsDidUpdateTheme),
                                               object: nil)

        translate()
        update()
        style()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: SettingsViewController.kSettingsDidUpdateTheme),
                                                  object: nil)
    }

    // MARK: -
    
    func style() {
        
    }

    func translate() {
        
    }
    
    func update() {
        
    }
}
