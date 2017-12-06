//
//  Webcam.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import Foundation
import ObjectMapper
import SwiftyUserDefaults
import RealmSwift

class Webcam: Object, Mappable {
    
    enum ContentType: String {
        case image = "image"
        case viewsurf = "viewsurf"
    }
    
    #if DEBUG
        static let refreshInterval: TimeInterval = 60 * 1
    #else
        static let refreshInterval: TimeInterval = 60 * 10
    #endif
    
    static let retryCount: Int = 3
    
    // Update from WS
    @objc dynamic var uid: Int = 0
    @objc dynamic var order: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var imageHD: String?
    @objc dynamic var imageLD: String?
    @objc dynamic var viewsurfLD: String?
    @objc dynamic var viewsurfHD: String?
    
    // MARK: - Camera content type
    @objc private dynamic var type: String?
    var contentType: ContentType {
        get {
            guard let stringType = type else { return .image }
            return ContentType(rawValue: stringType) ?? .image
        }
    }
    
    // Internal data
    @objc dynamic var favorite: Bool = false
    @objc dynamic var lastUpdate: Date?

    var tags = List<WebcamTag>()
    
    // MARK: -
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        var tagsArray = [String]()
        
        uid <- map["uid"]
        order <- map["order"]
        title <- map["title"]
        imageHD <- map["imageHD"]
        imageLD <- map["imageLD"]
        viewsurfLD <- map["viewsurfLD"]
        viewsurfHD <- map["viewsurfHD"]
        type <- map["type"]
        
        tagsArray <- map["tags"]
        setTags(from: tagsArray)
        
        let realm = try? Realm()
        if let webcam = realm?.object(ofType: Webcam.self, forPrimaryKey: uid) {
            lastUpdate = webcam.lastUpdate
            favorite = webcam.favorite
        }
    }
    
    override static func primaryKey() -> String? {
        return #keyPath(Webcam.uid)
    }
    
    // MARK: -
    
    func setTags(from arrayString: [String]) {
        for tag in arrayString {
            let webcamTag = WebcamTag()
            webcamTag.tag = tag
            tags.append(webcamTag)
        }
    }
    
    func isLowQualityOnly() -> Bool {
        var lowQuality: Bool = false
        
        switch contentType {
        case .image:
            lowQuality = (imageHD == nil)
        default:
            lowQuality = (viewsurfHD == nil)
        }
        
        return lowQuality
    }
    
    func isUpToDate() -> Bool {
        guard let update = lastUpdate else { return true }
        
        // 48h
        return (Date().timeIntervalSince1970 - update.timeIntervalSince1970) < (60 * 60 * 48)
    }
    
    func preferredImage() -> String? {
        if Defaults[.prefersHighQuality] {
            return imageHD ?? imageLD
        } else {
            return imageLD ?? imageHD
        }
    }
    
    func preferredViewsurf() -> String? {
        if Defaults[.prefersHighQuality] {
            return viewsurfHD ?? viewsurfLD
        } else {
            return viewsurfLD ?? viewsurfHD
        }
    }
}
