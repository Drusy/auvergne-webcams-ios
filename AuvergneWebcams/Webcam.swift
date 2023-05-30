//
//  Webcam.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import Foundation
import CoreLocation
import SwiftyUserDefaults
import RealmSwift

class Webcam: Object, Decodable {

    enum CodingKeys: String, CodingKey {
        case uid
        case order
        case title
        case imageHD
        case imageLD
        case viewsurf
        case video
        case mapImageName
        case isHidden = "hidden"
        case latitude
        case longitude
        case type
        case tags
    }
    
    enum ContentType: String {
        case image
        case viewsurf
        case video
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
    @objc dynamic var viewsurf: String?
    @objc dynamic var video: String?
    @objc dynamic var mapImageName: String?
    @objc dynamic var isHidden: Bool = false
    @objc dynamic var latitude: Double = -1
    @objc dynamic var longitude: Double = -1

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    private let sections: LinkingObjects<WebcamSection> = LinkingObjects(fromType: WebcamSection.self, property: "webcams")
    var section: WebcamSection? {
        return sections.first
    }
    
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

    override init() {
        super.init()
    }

    required init(from decoder: Decoder) throws {
        super.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(Int.self, forKey: .uid)
        self.order = try container.decode(Int.self, forKey: .order)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.imageHD = try container.decodeIfPresent(String.self, forKey: .imageHD)
        self.imageLD = try container.decodeIfPresent(String.self, forKey: .imageLD)
        self.viewsurf = try container.decodeIfPresent(String.self, forKey: .viewsurf)
        self.video = try container.decodeIfPresent(String.self, forKey: .video)
        self.mapImageName = try container.decodeIfPresent(String.self, forKey: .mapImageName)
        self.isHidden = try container.decodeIfPresent(Bool.self, forKey: .isHidden) ?? false
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? -1
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? -1
        self.type = try container.decodeIfPresent(String.self, forKey: .type)

        let tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        self.setTags(from: tags)
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
        case .viewsurf, .video:
            return false
        }
        
        return lowQuality
    }
    
    func isUpToDate() -> Bool {
        guard let update = lastUpdate else { return true }
        
        // 48h
        return (Date().timeIntervalSince1970 - update.timeIntervalSince1970) < (60 * 60 * 48)
    }
    
    func preferredImage() -> String? {
        if Defaults[\.prefersHighQuality] {
            return imageHD ?? imageLD
        } else {
            return imageLD ?? imageHD
        }
    }
    
    func preferredViewsurf() -> String? {
        return viewsurf
    }
}
