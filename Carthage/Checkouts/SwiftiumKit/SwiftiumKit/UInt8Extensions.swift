//
//  UInt8Extensions.swift
//  SwiftiumKit
//
//  Created by Richard Bergoin on 14/03/16.
//  Copyright © 2016 Openium. All rights reserved.
//

import Foundation

// MARK: Hex conversion

public protocol HexaStringConvertible {
    func toHexaString() -> String
}

extension UInt8: HexaStringConvertible {
    public func toHexaString() -> String {
        return String(format: "%02x", self)
    }
}
