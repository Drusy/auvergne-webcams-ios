//
//  OpenWeather.swift
//  AuvergneWebcams
//
//  Created by AuvergneWebcams on 08/02/2017.
//  Copyright © 2017 AuvergneWebcams. All rights reserved.
//

import Foundation
import ObjectMapper

class OpenWeather: Mappable {
    
    var id: Int = 800
    var main: String?
    var desc: String?
    var icon: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        main <- map["main"]
        desc <- map["description"]
        icon <- map["icon"]
    }
}
