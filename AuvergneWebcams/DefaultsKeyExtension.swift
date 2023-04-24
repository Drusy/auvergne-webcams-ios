//
//  DefaultsKeyExtension.swift
//  filesdnd
//
//  Created by Drusy on 01/11/2016.
//  Copyright © 2016 Files Drag & Drop. All rights reserved.
//

import SwiftyUserDefaults

extension DefaultsKeys {
    var firstConfigurationDone: DefaultsKey<Bool> { .init("firstConfigurationDone", defaultValue: false) }
    var shouldAutorefresh: DefaultsKey<Bool> { .init("autorefresh", defaultValue: false) }
    var prefersHighQuality: DefaultsKey<Bool> { .init("quality", defaultValue: false) }
    var autorefreshInterval: DefaultsKey<Double> { .init("autorefreshInterval", defaultValue: 600) }
    var currentVersion: DefaultsKey<String> { .init("currentVersion", defaultValue: "") }
    var cameraDetailCount: DefaultsKey<Int> { .init("cameraDetailCount", defaultValue: 0) }
    var appOpenCount: DefaultsKey<Int> { .init("appOpenCount", defaultValue: 0) }
    var mapboxStyle: DefaultsKey<String?> { .init("mapboxStyle") }
}
