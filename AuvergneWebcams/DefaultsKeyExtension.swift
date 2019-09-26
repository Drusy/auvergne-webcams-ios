//
//  DefaultsKeyExtension.swift
//  filesdnd
//
//  Created by Drusy on 01/11/2016.
//  Copyright © 2016 Files Drag & Drop. All rights reserved.
//

import SwiftyUserDefaults

extension DefaultsKeys {
    static let firstConfigurationDone = DefaultsKey<Bool>("firstConfigurationDone", defaultValue: false)
    static let shouldAutorefresh = DefaultsKey<Bool>("autorefresh", defaultValue: false)
    static let prefersHighQuality = DefaultsKey<Bool>("quality", defaultValue: false)
    static let autorefreshInterval = DefaultsKey<Double>("autorefreshInterval", defaultValue: 600)
    static let currentVersion = DefaultsKey<String>("currentVersion", defaultValue: "")
    static let cameraDetailCount = DefaultsKey<Int>("cameraDetailCount", defaultValue: 0)
    static let appOpenCount = DefaultsKey<Int>("appOpenCount", defaultValue: 0)
    static let mapboxStyle = DefaultsKey<String?>("mapboxStyle")
}
