//
//  AbstractRefreshViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 12/11/2016.
//
//

import UIKit
import SwiftyUserDefaults

class AbstractRefreshViewController: AbstractViewController {

    var refreshTimer: Timer?
    var lastUpdate: TimeInterval?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(startRefreshing),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(stopRefreshing),
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: nil)
        
        startRefreshing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stopRefreshing()
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIApplicationDidBecomeActive,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIApplicationWillResignActive,
                                                  object: nil)
    }
    
    // MARK: - 
    
    @objc private func refreshIfNeeded() {
        let now = NSDate().timeIntervalSinceReferenceDate
        if let lastUpdate = lastUpdate {
            let interval = now - lastUpdate
            if interval > Defaults[.autorefreshInterval] as TimeInterval {
                refresh(force: true)
            }
        } else {
            lastUpdate = now
        }
    }
    
    @objc private func stopRefreshing() {
        refreshTimer?.invalidate()
    }
    
    @objc private func startRefreshing() {
        refreshIfNeeded()
        
        refreshTimer = Timer.scheduledTimer(timeInterval: Defaults[.autorefreshInterval],
                                            target: self,
                                            selector: #selector(refresh),
                                            userInfo: nil,
                                            repeats: true)
    }
    
    // MARK: -
    
    @objc func refresh(force: Bool = false) {
        
    }
}
