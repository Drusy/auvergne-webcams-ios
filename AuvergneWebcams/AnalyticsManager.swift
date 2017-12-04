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
import Crashlytics

class AnalyticsManager {
    
    // MARK: - Private
    
    fileprivate static func logEvent(withName name: String, parameters: [String: NSObject]?) {
        #if !DEBUG
            Analytics.logEvent(name,
                               parameters: parameters)
            
            Answers.logContentView(withName: name,
                                   contentType: parameters?[AnalyticsParameterContentType] as? String,
                                   contentId: parameters?[AnalyticsParameterItemID] as? String,
                                   customAttributes: nil)
        #endif
    }
    
    fileprivate static func logShare(withName name: String, forType type: String) {
        #if !DEBUG
            Answers.logShare(withMethod: type,
                             contentName: name,
                             contentType: nil,
                             contentId: nil,
                             customAttributes: nil)
            
            let parameters = [
                AnalyticsParameterItemID: name as NSObject,
                AnalyticsParameterContentType: type as NSObject
            ]
            Analytics.logEvent(AnalyticsEventShare,
                               parameters: parameters)
        #endif
    }
    
    fileprivate static func logSearch(withText text: String) {
        #if !DEBUG
            Answers.logSearch(withQuery: text, customAttributes: nil)
            
            let parameters = [
                AnalyticsParameterSearchTerm: text as NSObject
            ]
            Analytics.logEvent(AnalyticsEventSearch,
                               parameters: parameters)
        #endif
    }
    
    // MARK: - Events
    
    static func logEvent(shareName name: String, forType type: String) {
        AnalyticsManager.logShare(withName: name, forType: type)
    }
    
    static func logEvent(searchText text: String) {
        AnalyticsManager.logSearch(withText: text)
    }
    
    static func logEvent(showSection section: WebcamSection) {
        guard let sectionName = section.title else { return }
        
        let parameters = [
            AnalyticsParameterItemCategory: sectionName as NSObject
        ]
        AnalyticsManager.logEvent(withName: AnalyticsEventViewItemList,
                                  parameters: parameters)
    }
    
    static func logEvent(showWebcam webcam: Webcam) {
        guard let webcamName = webcam.title else { return }
        
        let parameters = [
            AnalyticsParameterContentType: "webcam" as NSObject,
            AnalyticsParameterItemID: webcamName as NSObject
        ]
        AnalyticsManager.logEvent(withName: AnalyticsEventSelectContent,
                                  parameters: parameters)
    }
    
    static func logEvent(screenName screen: String) {
        let parameters = [
            AnalyticsParameterContentType: "screen" as NSObject,
            AnalyticsParameterItemID: screen as NSObject
        ]
        AnalyticsManager.logEvent(withName: AnalyticsEventSelectContent,
                                  parameters: parameters)
    }
    
    static func logEvent(set webcam: Webcam, asFavorite favorite: Bool) {
        guard let webcamName = webcam.title else { return }
        let contentType = favorite ? "favorite" : "unfavorite"
        
        let parameters = [
            AnalyticsParameterContentType: contentType as NSObject,
            AnalyticsParameterItemID: webcamName as NSObject
        ]
        AnalyticsManager.logEvent(withName: "favorite",
                                  parameters: parameters)
    }
    
    static func logEvent(button: String) {
        let parameters = [
            AnalyticsParameterContentType: "button" as NSObject,
            AnalyticsParameterItemID: button as NSObject
        ]
        AnalyticsManager.logEvent(withName: AnalyticsEventSelectContent,
                                  parameters: parameters)
    }
    
    static func logEventAppOpen() {
        AnalyticsManager.logEvent(withName: AnalyticsEventAppOpen,
                                  parameters: nil)
    }
    
    // MARK: - User Properties
    
    static func logUserProperties() {
        #if !DEBUG
            let refresh = Defaults[.shouldAutorefresh] ? "true" : "false"
            let refreshInterval = String(format: "%d", Defaults[.autorefreshInterval])
            let quality = Defaults[.prefersHighQuality] ? "high" : "low"
            
            Analytics.setUserProperty(refresh, forName: Analytics.refreshUserProperty)
            Analytics.setUserProperty(refreshInterval, forName: Analytics.refreshIntervalUserProperty)
            Analytics.setUserProperty(quality, forName: Analytics.webcamQualityUserProperty)
        #endif
    }
}
