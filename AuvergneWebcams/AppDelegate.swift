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
    
    lazy var mainViewController: WebcamCarouselViewController = {
        return WebcamCarouselViewController()
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        #if DEBUG
            UIFont.printFonts()
        #endif
        
        // SVProgressHUD
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setFont(UIFont.proximaNovaRegular(withSize: 15))
        SVProgressHUD.setDefaultMaskType(.black)
        
        // Alamofire
        NetworkActivityIndicatorManager.shared.isEnabled = true

        // Defaults
        let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        if !Defaults[.firstConfigurationDone] {
            Defaults[.firstConfigurationDone] = true
            
            // Defaults settings
            Defaults[.shouldAutorefresh] = true
            Defaults[.prefersHighQuality] = true
            Defaults[.autorefreshInterval] = Webcam.refreshInterval
        }
        
        // Realm
        var config = Realm.Configuration()
        let realmPath: URL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.fr.openium.AuvergneWebcams")!
            .appendingPathComponent("db.realm")
        config.fileURL = realmPath
        Realm.Configuration.defaultConfiguration = config
        
        let didPerformMigration = deleteRealmIfMigrationNeeded()
        #if DEBUG
            printRealmPath()
        #endif
        
        // Database init
        if didPerformMigration || Defaults[.currentVersion] != version {
            DownloadManager.shared.bootstrapRealmData()
        } else {
            // Let's init the download manager proxy
            _ = DownloadManager.shared
        }
        
        // Current version
        if Defaults[.currentVersion] != version {
            Defaults[.currentVersion] = version
        }
        
        // Firebase
        FirebaseApp.configure()
        AnalyticsManager.logUserProperties()

        // Cache
        let autorefreshInterval = Defaults[.autorefreshInterval]
        ImageCache.default.maxCachePeriodInSecond = autorefreshInterval as TimeInterval
        ImageCache.default.cleanExpiredDiskCache()
        
        // Shortcut items
        shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem
        
        // Update
        Siren.shared.delegate = self
        Siren.shared.alertType = .skip
        Siren.shared.checkVersion(checkType: .immediately)
        
        // Setup Window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.awDarkGray
        window?.rootViewController = loadingViewController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if let root = self.window?.rootViewController {
            QuickActionsService.shared.performActionFor(shortcutItem: shortcutItem, for: root)
        }
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
        Siren.shared.checkVersion(checkType: .daily)
        
        #if !DEBUG
            AnalyticsManager.logEventAppOpen()
            AnalyticsManager.logUserProperties()
        #endif
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Siren.shared.checkVersion(checkType: .daily)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
    
    func deleteRealmIfMigrationNeeded() -> Bool {
        var didPerformMigration = false
        
        do {
            _ = try Realm()
        } catch {
            print("Realm schema mismatch, deleting realm")
            
            Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
            _ = try! Realm()
            didPerformMigration = true
        }
        
        return didPerformMigration
    }
    
    func performRealmMigration() -> Void {
        // Inside your application(application:didFinishLaunchingWithOptions:)
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 0,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try? Realm()
    }
}

// MARK: - LoadingViewControllerDelegate

extension AppDelegate: LoadingViewControllerDelegate {
    func didFinishLoading(_: AbstractLoadingViewController) {
        let navigationController = NavigationController(rootViewController: mainViewController)
        window?.rootViewController = navigationController
        
        if let item = shortcutItem {
            shortcutItem = nil
            mainViewController.shortcutItem = item
        }
    }
}

// MARK: - SirenDelegate

extension AppDelegate: SirenDelegate {
    
    func sirenLatestVersionInstalled() {
        
    }
    
    func sirenDidFailVersionCheck(error: Error) {
        print("Failed to check app version : \(error.localizedDescription)")
    }

    func sirenUserDidLaunchAppStore() {
        
    }
    
    func sirenUserDidSkipVersion() {
        
    }
    
    func sirenUserDidCancel() {
        
    }
}

