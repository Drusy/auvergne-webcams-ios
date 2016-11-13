//
//  UIImageExtensionsTests.swift
//  SwiftiumKit
//
//  Created by Richard Bergoin on 19/10/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import XCTest

class UIImageExtensionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testColorizedImageWithColorBlack_shouldReturnBlackImage() {
        // Given
        let black = UIColor.black
        let sut = UIColor.blue.image(withSize: CGSize(width: 10, height: 10))!
        
        // When
        let image = sut.colorizedImage(withColor: black)
        
        // Expect
        let provider = (image?.cgImage)!.dataProvider
        let data = provider!.data
        let buffer = CFDataGetBytePtr(data)!
        let alphaInfo = image?.cgImage!.alphaInfo
        let alphaComponent:UInt8 = buffer[3]
        let redComponent:UInt8 = buffer[2]
        let greenComponent:UInt8 = buffer[1]
        let blueComponent:UInt8 = buffer[0]
        
        // Expect
        XCTAssertNotNil(image)
        XCTAssertEqual(CGImageAlphaInfo.premultipliedFirst, alphaInfo) // ARGB
        XCTAssertEqual(0xFF, alphaComponent)
        XCTAssertEqual(0x00, redComponent)
        XCTAssertEqual(0x00, greenComponent)
        XCTAssertEqual(0x00, blueComponent)
    }

}
