//
//  OpenWeather.swift
//  AuvergneWebcams
//
//  Created by Drusy on 07/03/2017.
//
//

import UIKit
import ObjectMapper

class OpenWeatherResponse: Queryable {
    
    var weathers = [OpenWeather]()
    var temperature: OpenTemperature?
    
    // MARK: -
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        weathers <- map["weather"]
        temperature <- map["main"]
    }
    
    // MARK: - Queryable
    
    class var webServiceScheme: String {
        return "http"
    }
    
    class var webServicePath: String {
        return "/data/2.5"
    }
    
    class var webServiceLastSegmentPath: String {
        return "/weather"
    }
    
    class var webServiceHost: String {
        return "api.openweathermap.org"
    }
    
    class func parameters() -> [String: Any]? {
        return [
            "appid": Configuration.openWeatherAPIKey
        ]
    }
}
