//
//  WebcamSection.swift
//  AuvergneWebcams
//
//  Created by Drusy on 09/11/2016.
//
//

import Foundation

class WebcamSectionResponse: Decodable, Queryable {
    var sections: [WebcamSection]

    enum CodingKeys: CodingKey {
        case sections
    }
    
    // MARK: - Queryable
    
    class var webServiceLastSegmentPath: String {
        return Configuration.distantJSONConfigurationFile
    }
}
