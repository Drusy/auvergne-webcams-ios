//
//  OpenWeather.swift
//  AuvergneWebcams
//
//  Created by AuvergneWebcams on 08/02/2017.
//  Copyright © 2017 AuvergneWebcams. All rights reserved.
//

import Foundation

class OpenTemperature: Decodable {
    var temperature: Double?
    var minTemperature: Double?
    var maxTemperature: Double?
    var pressure: Double?
    var humidity: Double?

    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case minTemperature = "temp_min"
        case maxTemperature = "temp_max"
        case pressure
        case humidity
    }
}
