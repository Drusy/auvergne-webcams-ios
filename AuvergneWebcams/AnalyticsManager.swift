//
//  AnalyticsManager.swift
//  AuvergneWebcams
//
//  Created by Drusy on 21/02/2017.
//
//

import UIKit
import Firebase
import FirebaseAnalytics
import SwiftyUserDefaults

class AnalyticsManager {
    
    // TODO: Refresh
    // TODO: Settings
    // TODO: About
    // TODO: Save
    // TODO: Openium
    // TODO: Pirates
    // TODO: Noter l'app
    
    // MARK: - Events
    
    static func logEvent(shareName name: String, forType type: String) {
        
        let parameters = [
            kFIRParameterItemID: name as NSObject,
            kFIRParameterContentType: type as NSObject
        ]
        FIRAnalytics.logEvent(withName: kFIREventShare,
                              parameters: parameters)
    }
    
    static func logEvent(searchText text: String) {
        
        let parameters = [
            kFIRParameterSearchTerm: text as NSObject
        ]
        FIRAnalytics.logEvent(withName: kFIREventSearch,
                              parameters: parameters)
    }
    
    static func logEvent(showSection section: WebcamSection) {
        guard let sectionName = section.title else { return }
        
        let parameters = [
            kFIRParameterItemCategory: sectionName as NSObject
        ]
        FIRAnalytics.logEvent(withName: kFIREventViewItemList,
                              parameters: parameters)
    }
    
    static func logEvent(showWebcam webcam: Webcam) {
        guard let webcamName = webcam.title else { return }
        
        let parameters = [
            kFIRParameterContentType: "webcam" as NSObject,
            kFIRParameterItemID: webcamName as NSObject
        ]
        FIRAnalytics.logEvent(withName: kFIREventSelectContent,
                              parameters: parameters)
    }
    
    static func logEvent(screenName screen: String) {
        let parameters = [
            kFIRParameterContentType: "screen" as NSObject,
            kFIRParameterItemID: screen as NSObject
        ]
        FIRAnalytics.logEvent(withName: kFIREventSelectContent,
                              parameters: parameters)
    }
    
    static func logEvent(button: String) {
        let parameters = [
            kFIRParameterContentType: "button" as NSObject,
            kFIRParameterItemID: button as NSObject
        ]
        FIRAnalytics.logEvent(withName: kFIREventSelectContent,
                              parameters: parameters)
    }
    
    static func logEventAppOpen() {
        FIRAnalytics.logEvent(withName: kFIREventAppOpen,
                              parameters: nil)
    }
    
    // MARK: - User Properties
    
    static func logUserProperties() {
        let refresh = Defaults[.shouldAutorefresh] ? "true" : "false"
        let refreshInterval = String(format: "%d", Defaults[.autorefreshInterval])
        let quality = Defaults[.prefersHighQuality] ? "high" : "low"
        
        FIRAnalytics.setUserPropertyString(refresh, forName: FIRAnalytics.refreshUserProperty)
        FIRAnalytics.setUserPropertyString(refreshInterval, forName: FIRAnalytics.refreshIntervalUserProperty)
        FIRAnalytics.setUserPropertyString(quality, forName: FIRAnalytics.webcamQualityUserProperty)
    }
}
