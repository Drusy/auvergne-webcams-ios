//
//  Configuration.swift
//  AuvergneWebcams
//
//  Created by Drusy on 23/03/2017.
//
//

import Foundation

class Configuration {
    static var applicationName: String {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        return appName ?? "Auvergne Webcams"
    }
}
