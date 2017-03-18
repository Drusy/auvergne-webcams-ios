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
            FIRAnalytics.logEvent(withName: name,
                                  parameters: parameters)
        
            Answers.logContentView(withName: name,
                                   contentType: parameters?[kFIRParameterContentType] as? String,
                                   contentId: parameters?[kFIRParameterItemID] as? String,
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
                kFIRParameterItemID: name as NSObject,
                kFIRParameterContentType: type as NSObject
            ]
            FIRAnalytics.logEvent(withName: kFIREventShare,
                                  parameters: parameters)
        #endif
    }
    
    fileprivate static func logSearch(withText text: String) {
        #if !DEBUG
            Answers.logSearch(withQuery: text, customAttributes: nil)
            
            let parameters = [
                kFIRParameterSearchTerm: text as NSObject
            ]
            FIRAnalytics.logEvent(withName: kFIREventSearch,
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
            kFIRParameterItemCategory: sectionName as NSObject
        ]
        AnalyticsManager.logEvent(withName: kFIREventViewItemList,
                                  parameters: parameters)
    }
    
    static func logEvent(showWebcam webcam: Webcam) {
        guard let webcamName = webcam.title else { return }
        
        let parameters = [
            kFIRParameterContentType: "webcam" as NSObject,
            kFIRParameterItemID: webcamName as NSObject
        ]
        AnalyticsManager.logEvent(withName: kFIREventSelectContent,
                                  parameters: parameters)
    }
    
    static func logEvent(screenName screen: String) {
        let parameters = [
            kFIRParameterContentType: "screen" as NSObject,
            kFIRParameterItemID: screen as NSObject
        ]
        AnalyticsManager.logEvent(withName: kFIREventSelectContent,
                                  parameters: parameters)
    }
    
    static func logEvent(set webcam: Webcam, asFavorite favorite: Bool) {
        guard let webcamName = webcam.title else { return }
        let contentType = favorite ? "favorite" : "unfavorite"
        
        let parameters = [
            kFIRParameterContentType: contentType as NSObject,
            kFIRParameterItemID: webcamName as NSObject
        ]
        AnalyticsManager.logEvent(withName: "favorite",
                                  parameters: parameters)
    }
    
    static func logEvent(button: String) {
        let parameters = [
            kFIRParameterContentType: "button" as NSObject,
            kFIRParameterItemID: button as NSObject
        ]
        AnalyticsManager.logEvent(withName: kFIREventSelectContent,
                                  parameters: parameters)
    }
    
    static func logEventAppOpen() {
        AnalyticsManager.logEvent(withName: kFIREventAppOpen,
                                  parameters: nil)
    }
    
    // MARK: - User Properties
    
    static func logUserProperties() {
        #if !DEBUG
            let refresh = Defaults[.shouldAutorefresh] ? "true" : "false"
            let refreshInterval = String(format: "%d", Defaults[.autorefreshInterval])
            let quality = Defaults[.prefersHighQuality] ? "high" : "low"
            
            FIRAnalytics.setUserPropertyString(refresh, forName: FIRAnalytics.refreshUserProperty)
            FIRAnalytics.setUserPropertyString(refreshInterval, forName: FIRAnalytics.refreshIntervalUserProperty)
            FIRAnalytics.setUserPropertyString(quality, forName: FIRAnalytics.webcamQualityUserProperty)
        #endif
    }
}
