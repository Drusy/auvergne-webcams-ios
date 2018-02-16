//
//  DefaultsKeyExtension.swift
//  filesdnd
//
//  Created by Drusy on 01/11/2016.
//  Copyright © 2016 Files Drag & Drop. All rights reserved.
//

import SwiftyUserDefaults

extension DefaultsKeys {
    static let firstConfigurationDone = DefaultsKey<Bool>("firstConfigurationDone")
    static let shouldAutorefresh = DefaultsKey<Bool>("autorefresh")
    static let prefersHighQuality = DefaultsKey<Bool>("quality")
    static let autorefreshInterval = DefaultsKey<Double>("autorefreshInterval")
    static let currentVersion = DefaultsKey<String>("currentVersion")
    static let cameraDetailCount = DefaultsKey<Int>("cameraDetailCount")
    static let appOpenCount = DefaultsKey<Int>("appOpenCount")
    static let mapboxStyle = DefaultsKey<String?>("mapboxStyle")
}
