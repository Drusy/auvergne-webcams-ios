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
import FirebaseCore
import FirebaseCrashlytics
import RealmSwift
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var shortcutItem: UIApplicationShortcutItem?
    
    lazy var loadingViewController: LoadingViewController = {
        let loadingViewController = LoadingViewController()
        loadingViewController.delegate = self
        return loadingViewController
    }()
    
    lazy var mainViewController: HomeViewController = {
        return HomeViewController()
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
            UIFont.printFonts()
        #endif
        
        // SVProgressHUD
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setFont(UIFont.proximaNovaRegular(withSize: 15))
        SVProgressHUD.setDefaultMaskType(.black)

        // Defaults
        let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        if !Defaults[\.firstConfigurationDone] {
            Defaults[\.firstConfigurationDone] = true
            
            // Defaults settings
            Defaults[\.shouldAutorefresh] = true
            Defaults[\.prefersHighQuality] = true
            Defaults[\.autorefreshInterval] = Webcam.refreshInterval
        }
        
        // Realm
        var config = Realm.Configuration()
        let realmPath: URL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.fr.openium.AuvergneWebcams")!
            .appendingPathComponent("db.realm")
        config.fileURL = realmPath
        config.deleteRealmIfMigrationNeeded = true
        Realm.Configuration.defaultConfiguration = config
        
        #if DEBUG
            printRealmPath()
        #endif
        
        // Database init
        if Defaults[\.currentVersion] != version {
            DownloadManager.shared.bootstrapRealmData()
        } else {
            // Let's init the download manager proxy
            _ = DownloadManager.shared
        }
        
        // Current version
        if Defaults[\.currentVersion] != version {
            Defaults[\.currentVersion] = version
        }
        
        // Firebase
        FirebaseApp.configure()
        AnalyticsManager.logUserProperties()

        // Cache
        let autorefreshInterval = Defaults[\.autorefreshInterval]
        ImageCache.default.memoryStorage.config.expiration = .seconds(autorefreshInterval as TimeInterval)
        ImageCache.default.cleanExpiredDiskCache()
        
        // Shortcut items
        shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem
        
        // Update
        Siren.shared.wail()
        
        // Setup Window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.awDarkGray
        window?.rootViewController = loadingViewController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if let navigationController = mainViewController.currentViewController as? UINavigationController {
            QuickActionsService.shared.performActionFor(shortcutItem: shortcutItem, for: navigationController)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {        
        #if !DEBUG
            AnalyticsManager.logEventAppOpen()
            AnalyticsManager.logUserProperties()
        #endif
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    
    // MARK: - Realm
    
    func printRealmPath() {
        guard let realm = try? Realm() else { return }
        guard let path = realm.configuration.fileURL?.path else { return }
        
        print(path)
    }
}

// MARK: - LoadingViewControllerDelegate

extension AppDelegate: LoadingViewControllerDelegate {
    func didFinishLoading(_: AbstractLoadingViewController) {
        window?.rootViewController = mainViewController
        
        if let item = shortcutItem {
            shortcutItem = nil
            mainViewController.listViewController.shortcutItem = item
        }
    }
}
