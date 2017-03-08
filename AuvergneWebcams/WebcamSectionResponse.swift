//
//  WebcamSection.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import Foundation
import ObjectMapper

class WebcamSectionResponse: Queryable {

    var sections = [WebcamSection]()
    
    // MARK: - 
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        sections <- map["sections"]
    }
    
    // MARK: - Queryable
    
    class var webServiceLastSegmentPath: String {
        return "aw-config.json"
    }
}
