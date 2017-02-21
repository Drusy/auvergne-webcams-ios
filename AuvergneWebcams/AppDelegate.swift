//
//  AppDelegate.swift
//  AuvergneWebcams
//
//  Created by Drusy on 07/11/2016.
//
//

import UIKit
import Kingfisher
import Siren
import SwiftyUserDefaults
import Fabric
import Crashlytics
import AlamofireNetworkActivityIndicator
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var loadingViewController: LoadingViewController = {
        let loadingViewController = LoadingViewController()
        loadingViewController.delegate = self
        return loadingViewController
    }()
    
    lazy var mainViewController: WebcamCarouselViewController = {
        return WebcamCarouselViewController()
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        #if DEBUG
            UIFont.printFonts()
        #endif
        
        // Alamofire
        NetworkActivityIndicatorManager.shared.isEnabled = true

        // Defaults
        if !Defaults[.firstConfigurationDone] {
            Defaults[.firstConfigurationDone] = true
            
            // Defaults settings
            Defaults[.shouldAutorefresh] = true
            Defaults[.prefersHighQuality] = true
            Defaults[.autorefreshInterval] = Webcam.refreshInterval
        }
        
        // Firebase
        FIRApp.configure()
        AnalyticsManager.logUserProperties()

        // Cache
        let autorefreshInterval = Defaults[.autorefreshInterval]
        ImageCache.default.maxCachePeriodInSecond = autorefreshInterval as TimeInterval
        ImageCache.default.cleanExpiredDiskCache()
        
        // Update
        Siren.sharedInstance.alertType = .skip
        Siren.sharedInstance.checkVersion(checkType: .immediately)
        
        let navigationController = NavigationController(rootViewController: mainViewController)
        
        // Setup Window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Siren.sharedInstance.checkVersion(checkType: .daily)
        
        AnalyticsManager.logEventAppOpen()
        AnalyticsManager.logUserProperties()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Siren.sharedInstance.checkVersion(checkType: .daily)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK: - LoadingViewControllerDelegate

extension AppDelegate: LoadingViewControllerDelegate {
    func didFinishLoading(_: LoadingViewController) {
        
    }
}

