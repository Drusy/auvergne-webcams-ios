//
//  WebcamSection.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import Foundation
import ObjectMapper

class WebcamSectionResponse: QueryableEntity {

    var sections = [WebcamSection]()
    
    // MARK: - 
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        sections <- map["sections"]
    }
    
    // MARK: - Mappable
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return WebcamSectionResponse()
    }
    
    // MARK: - Queryable
    
    override class var webServiceLastSegmentPath: String {
        return "aw-config.json"
    }
}
