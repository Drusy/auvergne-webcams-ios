//
//  WebcamSection.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import Foundation
import ObjectMapper
import RealmSwift

class WebcamSection: Object, Mappable {
    dynamic var uid: Int = 0
    dynamic var order: Int = 0
    dynamic var title: String?
    dynamic var imageName: String?

    var webcams = List<Webcam>()
    var image: UIImage? {
        guard let name = imageName else { return nil }
        
        return UIImage(named: name)
    }
    
    // MARK: - 
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        var webcamsArray = [Webcam]()
        
        uid <- map["uid"]
        order <- map["order"]
        title <- map["title"]
        imageName <- map["imageName"]
        webcamsArray <- map["webcams"]
        
        webcams.append(contentsOf: webcamsArray)
    }
    
    override static func primaryKey() -> String? {
        return #keyPath(WebcamSection.uid)
    }
    
    // MARK: - 
    
    func webcamCountLabel() -> String {
        if webcams.count == 1 {
            return "1 webcam"
        } else {
            return "\(webcams.count) webcams"
        }
    }
}
