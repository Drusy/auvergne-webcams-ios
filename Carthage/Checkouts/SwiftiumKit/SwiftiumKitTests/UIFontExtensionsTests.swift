//
//  UIFontExtensionsTests.swift
//  SwiftiumKit
//
//  Created by Richard Bergoin on 19/10/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import XCTest
import SwiftiumKit

class UIFontExtensionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFindFontHavingNameLike_shouldReturnEmptyList() {
        // Given
        let unavailableFontName = "An Unavailable Font Name"
        
        // When
        let findedFonts = UIFont.findFont(havingNameLike: unavailableFontName)
        
        // Expect
        XCTAssertEqual(findedFonts, [String]())
    }
    
    func testFindFontHavingNameLike_shouldReturnSomeNames() {
        // Given
        let fontName = "Helvetica Bold"
        let expectedFoundName = "Helvetica-Bold"
        
        // When
        let findedFonts = UIFont.findFont(havingNameLike: fontName)
        
        // Expect
        XCTAssertTrue(findedFonts.contains(expectedFoundName))
    }
    
}
