//
//  QuickActionsService.swift
//  AuvergneWebcams
//
//  Created by Alexandre Caillot on 12/06/2017.
//
//

import Foundation
import RealmSwift

enum QuickActionsEnum {
    case add
    case delete
}

class QuickActionsService {
    
    static let shared = QuickActionsService()
    private init() { }
    
    let defaultTypePrefix = "fr.openium.AuvergneWebcams.quickAction."
    var realm = try! Realm()
    let maxFav: Int = 4
    let maxQuickActionItem: Int = 4
    
    let containsKey = "Contains"
    let indexKey = "Index"
    
    func registerQuickActions() {
        guard UIApplication.shared.shortcutItems?.isEmpty ?? false else { return }
        
        var shortcutItems = Array<UIApplicationShortcutItem>()
        let favoriteWebcams = realm.objects(Webcam.self).filter("%K = true", #keyPath(Webcam.favorite)).prefix(maxFav)
        
        for fwb in favoriteWebcams {
            let type = QuickActionsService.shared.defaultTypePrefix + "\(fwb.uid)"
            if let title = fwb.title {
                let shortcutItem: UIApplicationShortcutItem
                
                if #available(iOS 9.1, *) {
                    shortcutItem = UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .favorite), userInfo: nil)
                } else {
                    shortcutItem = UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: nil, icon: nil, userInfo: nil)
                }
                
                shortcutItems.append(shortcutItem)
            }
        }
        UIApplication.shared.shortcutItems = shortcutItems
    }
    
    func performActionFor(shortcutItem: UIApplicationShortcutItem, for root: UIViewController, animated: Bool = true) {
        
        if shortcutItem.type.contains(QuickActionsService.shared.defaultTypePrefix) {
            guard let idString = shortcutItem.type.components(separatedBy: ".").last,
                let id = Int(idString),
                let webcam = realm.object(ofType: Webcam.self, forPrimaryKey: id)
            else {
                return
            }
            
            let webcamDetailViewController = WebcamDetailViewController(webcam: webcam)
            if let nav = root as? NavigationController {
                nav.popToRootViewController(animated: false)
                nav.pushViewController(webcamDetailViewController, animated: animated)
            }
        }
    }
    
    func quickActionEdit(webcam: Webcam, value: QuickActionsEnum) {
        guard let shortcutItems: Array<UIApplicationShortcutItem> = UIApplication.shared.shortcutItems else { return }
        
        if webcam.favorite && shortcutItems.count < 4 {
            quickActionsFavorite(webcam: webcam, value: value)
        } else {
            quickActionsRecent(webcam: webcam, value: value)
        }
    }
    
    // MARK: - Private

    private func quickActionsFavorite(webcam: Webcam, value: QuickActionsEnum) {
        guard var shortcutItems: Array<UIApplicationShortcutItem> = UIApplication.shared.shortcutItems else { return }
        
        let type = QuickActionsService.shared.defaultTypePrefix + "\(webcam.uid)"
        if let title = webcam.title {
            let shortcutItem: UIApplicationShortcutItem
            
            if #available(iOS 9.1, *) {
                shortcutItem = UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .favorite), userInfo: nil)
            } else {
                shortcutItem = UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: nil, icon: nil, userInfo: nil)
            }
            
            switch value {
            case .add:
                shortcutItems = removeRecentQuickAction(in: shortcutItems)
                if !containsInQuickAction(webcam: webcam, in: shortcutItems) {
                    shortcutItems.append(shortcutItem)
                }
            case .delete:
                if let index = shortcutItems.index(of: shortcutItem) {
                    shortcutItems.remove(at: index)
                }
            }
            
            UIApplication.shared.shortcutItems = shortcutItems
        }
    }
    
    private func quickActionsRecent(webcam: Webcam, value: QuickActionsEnum) {
        guard var shortcutItems: Array<UIApplicationShortcutItem> = UIApplication.shared.shortcutItems else { return }
        
        switch value {
        case .add:
            let type = QuickActionsService.shared.defaultTypePrefix + "\(webcam.uid)"
            if let title = webcam.title {
                let shortcutItem: UIApplicationShortcutItem
                
                if #available(iOS 9.1, *) {
                    shortcutItem = UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .time), userInfo: nil)
                } else {
                    shortcutItem = UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: nil, icon: nil, userInfo: nil)
                }
                
                if !containsInQuickAction(webcam: webcam, in: shortcutItems) {
                    shortcutItems = removeRecentQuickAction(in: shortcutItems)
                    shortcutItems.insert(shortcutItem, at: 0)
                }
            }
        case .delete:
            shortcutItems.remove(at: 0)
        }
        UIApplication.shared.shortcutItems = shortcutItems
    }
    
    private func containsInQuickAction(webcam: Webcam, in array: Array<UIApplicationShortcutItem>) -> Bool {
        let type = QuickActionsService.shared.defaultTypePrefix + "\(webcam.uid)"
        
        for item in array {
            if item.type == type {
                return true
            }
        }
        
        return false
    }
    
    private func removeRecentQuickAction(in array: Array<UIApplicationShortcutItem> ) -> Array<UIApplicationShortcutItem> {
        var shortcutItems = array
        
        for (index, shortcutItem) in shortcutItems.enumerated() {
            if #available(iOS 9.1, *) {
                if shortcutItem.icon == UIApplicationShortcutIcon(type: .time) {
                    shortcutItems.remove(at: index)
                }
            }
        }
        return shortcutItems
    }
}
