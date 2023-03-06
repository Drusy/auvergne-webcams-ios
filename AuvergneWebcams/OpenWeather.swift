//
//  OpenWeather.swift
//  AuvergneWebcams
//
//  Created by AuvergneWebcams on 08/02/2017.
//  Copyright © 2017 AuvergneWebcams. All rights reserved.
//

import Foundation

class OpenWeather: Decodable {
    var id: Int = 800
    var main: String?
    var desc: String?
    var icon: String?

    enum CodingKeys: String, CodingKey {
        case id
        case main
        case desc = "description"
        case icon
    }
}
