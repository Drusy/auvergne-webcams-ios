//
//  UIColor+OSKAdditionsTests.swift
//  OpeniumSwiftKit
//
//  Created by Richard Bergoin on 21/07/15.
//  Copyright (c) 2015 Openium. All rights reserved.
//

import UIKit
import XCTest
import SwiftiumKit

class UIColor_OSKAdditionsTests: XCTestCase {

    let r18:CGFloat = 18.0 / 255.0
    let g18:CGFloat = 18.0 / 255.0
    let b18:CGFloat = 18.0 / 255.0
    let a22:CGFloat = 22.0 / 255.0
    let precision:CGFloat = 0.00001
    
    func testColorFromRGB() {
        // Given
        let rgbValue:Int64 = 0x121212
    
        // When
        let c = UIColor(rgb: rgbValue)
    
        // Expect
        let f = c.cgColor.components
        XCTAssertEqualWithAccuracy(f![0], r18, accuracy: precision)
        XCTAssertEqualWithAccuracy(f![1], g18, accuracy: precision)
        XCTAssertEqualWithAccuracy(f![2], b18, accuracy: precision)
        XCTAssertEqualWithAccuracy(f![3], 1.0, accuracy: precision)
    }

    func testColorFromRGBA_alpha0() {
        // Given
        let rgbValue:Int64 = 0x12121200
    
        // When
        let c = UIColor(rgba: rgbValue)
    
        // Expect
        let f = c.cgColor.components
        XCTAssertEqualWithAccuracy(f![0], r18, accuracy: precision)
        XCTAssertEqualWithAccuracy(f![1], g18, accuracy: precision)
        XCTAssertEqualWithAccuracy(f![2], b18, accuracy: precision)
        XCTAssertEqualWithAccuracy(f![3], 0.0, accuracy: precision)
    }
    
    func testColorFromRGBA() {
        // Given
        let color:Int64 = 0x12121216
    
        // When
        let c = UIColor(rgba: color)
    
        // Expect
        let f = c.cgColor.components
        XCTAssertEqualWithAccuracy(f![0], r18, accuracy: precision)
        XCTAssertEqualWithAccuracy(f![1], g18, accuracy: precision)
        XCTAssertEqualWithAccuracy(f![2], b18, accuracy: precision)
        XCTAssertEqualWithAccuracy(f![3], a22, accuracy: precision)
    }
    
    func testColorFromARGB() {
        // Given
        let color:Int64 = 0x16121212
        
        // When
        let c = UIColor(argb: color)
        
        // Expect
        let f = c.cgColor.components
        XCTAssertEqualWithAccuracy(f![0], r18, accuracy: precision)
        XCTAssertEqualWithAccuracy(f![1], g18, accuracy: precision)
        XCTAssertEqualWithAccuracy(f![2], b18, accuracy: precision)
        XCTAssertEqualWithAccuracy(f![3], a22, accuracy: precision)
    }
    
    func testImageWithSize_shouldReturnImageWithCorrectSize() {
        // Given
        let sut = UIColor.red
        let size = CGSize(width: 10, height: 10)
        
        // When
        let image = sut.image(withSize: size)
        
        // Expect
        XCTAssertNotNil(image)
        XCTAssertEqual(size, image?.size)
    }
    
    func testImageWithSize_shouldReturnImageWithCorrectColor() {
        // Given
        let sut = UIColor.green
        let size = CGSize(width: 10, height: 10)

        // When
        let image = sut.image(withSize: size)
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
        XCTAssertEqual(0xFF, greenComponent)
        XCTAssertEqual(0x00, blueComponent)
    }
}
