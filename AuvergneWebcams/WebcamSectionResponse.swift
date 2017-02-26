//
//  WebcamSection.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import Foundation
import ObjectMapper

class WebcamSectionResponse: Mappable {

    var sections = [WebcamSection]()
    
    // MARK: - 
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {        
        sections <- map["sections"]
    }
}
