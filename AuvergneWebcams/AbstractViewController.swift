
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

    // MARK: - Overridable
    
    func style() {
        
    }

    func translate() {
        
    }
    
    func update() {
        
    }
    
    // MARK: -
    
    func isReachable() -> Bool {
        return (reachability == nil || (reachability != nil && reachability!.isReachable))
    }
    
    func share(_ title: String? = nil, link: String? = nil, image: UIImage? = nil, fromBarButton barButton: UIBarButtonItem? = nil) {
        var items = [Any]()
        
        if let title = title {
            items.append(title as Any)
        }
        
        if let image = image {
            items.append(image)
        }
        
        if let content = link {
            if let url = URL(string: content) {
                items.append(url as Any)
            }
        }
        
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = barButton

        if let title = title {
            activityController.setValue(title, forKey: "subject")
        }
        
        self.present(activityController, animated: true, completion: nil)
    }
}
