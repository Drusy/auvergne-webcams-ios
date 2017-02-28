//
//  RequestExtension.swift
//  AuvergneWebcams
//
//  Created by AuvergneWebcams on 20/07/16.
//  Copyright © 2016 AuvergneWebcams. All rights reserved.
//

import Alamofire

extension Request {
    public func debugLog() -> Self {
        #if DEBUG
            debugPrint(self)
        #endif
        return self
    }
}
