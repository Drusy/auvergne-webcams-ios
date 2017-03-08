//
//  OpenWeather.swift
//  AuvergneWebcams
//
//  Created by AuvergneWebcams on 08/02/2017.
//  Copyright © 2017 AuvergneWebcams. All rights reserved.
//

import Foundation
import ObjectMapper

class OpenTemperature: Mappable {
    
    var temperature: Double?
    var minTemperature: Double?
    var maxTemperature: Double?
    var pressure: Double?
    var humidity: Double?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        temperature <- map["temp"]
        minTemperature <- map["temp_min"]
        maxTemperature <- map["temp_max"]
        pressure <- map["pressure"]
        humidity <- map["humidity"]
    }
}
