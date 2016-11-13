//
//  DictionaryOperatorsTests.swift
//  SwiftiumKit
//
//  Created by Drusy on 04/11/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import XCTest

import SwiftiumKit

class DictionaryOperatorsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testConcatDictionary_usingAssignmentBySum_shouldFillDictionary() {
        // Given
        var given: [Int: String] = [ 1: "String 1" ]
        let toAdd: [Int: String] = [ 2: "String 2" ]
        
        // When
        given += toAdd
        
        // Expect
        XCTAssertEqual(given, [
            1: "String 1",
            2: "String 2"
            ]
        )
    }
    
    func testConcatDictionary_usingAssignmentBySum_shouldReplaceDictionaryValues() {
        // Given
        var given: [Int: String] = [
            1: "String 1",
            2: "String 2"
        ]
        let expected: [Int: String] = [
            1: "Remplacement 1",
            2: "Remplacement 2"
        ]
        
        // When
        given += expected
        
        // Expect
        XCTAssertEqual(given, expected)
    }
    
    func testConcatDictionary_usingAddition_shouldFillDictionary() {
        // Given
        let given: [Int: String] = [ 1: "String 1" ]
        let toAdd: [Int: String] = [ 2: "String 2" ]
        
        // When
        let result = given + toAdd
        
        // Expect
        XCTAssertEqual(result, [
            1: "String 1",
            2: "String 2"
            ]
        )
    }
    
    func testConcatDictionary_usingAddition_shouldReplaceDictionaryValues() {
        // Given
        let given: [Int: String] = [
            1: "String 1",
            2: "String 2"
        ]
        let expected: [Int: String] = [
            1: "Remplacement 1",
            2: "Remplacement 2"
        ]
        
        // When
        let result = given + expected
        
        // Expect
        XCTAssertEqual(result, expected)
    }
}
