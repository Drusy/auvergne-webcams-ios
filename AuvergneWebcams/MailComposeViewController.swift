//
//  MailComposeViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 22/02/2017.
//
//

import UIKit
import MessageUI

class MailComposeViewController: MFMailComposeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil
    }
}
