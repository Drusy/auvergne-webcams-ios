//
//  StringObject.swift
//  AuvergneWebcams
//
//  Created by Drusy on 07/10/2016.
//  Copyright © 2016 AuvergneWebcams. All rights reserved.
//

import Foundation
import RealmSwift

class WebcamTag: Object {
    dynamic var tag: String = ""
    
    override static func primaryKey() -> String? {
        return #keyPath(WebcamTag.tag)
    }
}
