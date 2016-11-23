
//
//  AbstractViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit
import Reachability

class AbstractViewController: UIViewController {

    let reachability = Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(style),
                                               name: NSNotification.Name.SettingsDidUpdateTheme,
                                               object: nil)

        translate()
        update()
        style()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.SettingsDidUpdateTheme,
                                                  object: nil)
    }

    // MARK: -
    
    func isReachable() -> Bool {
        return (reachability == nil || (reachability != nil && reachability!.isReachable))
    }
    
    func style() {
        
    }

    func translate() {
        
    }
    
    func update() {
        
    }
}
