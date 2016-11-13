//
//  UInt8ExtensionsTests.swift
//  SwiftiumKit
//
//  Created by Richard Bergoin on 14/03/16.
//  Copyright © 2016 Openium. All rights reserved.
//

import XCTest

import SwiftiumKit

class UInt8ExtensionsTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testToHexaString_withBB_shouldReturnLowercaseHexStringBB() {
        // Given
        let i = UInt8(0xbb)
        
        // When
        let hexString = i.toHexaString()
        
        // Expect
        XCTAssertEqual(hexString, "bb")
    }

}
