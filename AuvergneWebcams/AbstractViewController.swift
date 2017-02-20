
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

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        translate()
        update()
        style()
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
    
    func share(_ title: String? = nil, link: String? = nil, image: UIImage? = nil, fromView view: UIView? = nil) {
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
        activityController.popoverPresentationController?.sourceView = view

        if let title = title {
            activityController.setValue(title, forKey: "subject")
        }
        
        self.present(activityController, animated: true, completion: nil)
    }
}
