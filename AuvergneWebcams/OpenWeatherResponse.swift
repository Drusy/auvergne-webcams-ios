//
//  OpenWeather.swift
//  AuvergneWebcams
//
//  Created by Drusy on 07/03/2017.
//
//

import UIKit

class OpenWeatherResponse: Queryable, Decodable {
    var weathers = [OpenWeather]()
    var temperature: OpenTemperature?

    enum CodingKeys: String, CodingKey {
        case weathers = "weather"
        case temperature
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
