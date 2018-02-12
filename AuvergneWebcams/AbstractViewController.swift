
//
//  AbstractViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import UIKit
import Reachability
import Crashlytics

class AbstractViewController: UIViewController {

    let reachability = Reachability()
    var didLayoutSubviews = false

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        translate()
        update()
        style()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didLayoutSubviews {
            didLayoutSubviews = true
            
            onAppearConfiguration()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Overridable
    
    func onAppearConfiguration() {
        
    }
    
    func style() {
        
    }

    func translate() {
        
    }
    
    func update() {
        
    }
    
    // MARK: -
    
    func showAlertView(for error: Error) {
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        let ac = UIAlertController(title: "Erreur",
                                   message: error.localizedDescription,
                                   preferredStyle: .alert)
        ac.addAction(okAction)
        present(ac, animated: true)
        
        Crashlytics.sharedInstance().recordError(error)
    }
    
    func showAlertView(with message: String) {
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        let ac = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
        ac.addAction(okAction)
        present(ac, animated: true)
    }
    
    func isReachable() -> Bool {
        return (reachability == nil || (reachability != nil && reachability!.connection != .none))
    }
    
    func share(_ title: String? = nil, url: URL? = nil, image: UIImage? = nil, fromView view: UIView? = nil) {
        var items = [Any]()
        
        if let title = title {
            if let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
                items.append("\(title)\n\nPartagé depuis \(appName)" as Any)
            } else {
                items.append(title as Any)
            }
        }
        
        if let image = image {
            items.append(image)
        }
        
        if let url = url{
            items.append(url as Any)
        }
        
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = view
        
        activityController.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            guard let title = title else { return }
            
            let completedAsString = completed ? "completed" : "canceled"
            let activity: String = activityType?.rawValue ?? "unknown"
            let type = "\(activity)-\(completedAsString)"
            
            AnalyticsManager.logEvent(shareName: title, forType: type)
        }

        if let title = title {
            activityController.setValue(title, forKey: "subject")
        }
        
        self.present(activityController, animated: true, completion: nil)
    }
}
