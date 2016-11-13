//
//  NSDataExtensionsTests.swift
//  SwiftiumKit
//
//  Created by Richard Bergoin on 14/03/16.
//  Copyright © 2016 Openium. All rights reserved.
//

import XCTest

import SwiftiumKit

class NSDataExtensionsTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: hex
    
    func testBase16EncodedString() {
        // Given
        let data = Data(bytesArray: [UInt8(0x0b), 0xad, 0xf0, 0x0d])!
        
        // When
        let hex = data.base16EncodedString()
        
        // Expect
        XCTAssertEqual(hex, "0badf00d")
    }
    
    func testBase16EncodedStringBis() {
        // Given
        let data = Data(bytesArray: [UInt8(0xde), 0xad, 0xbe, 0xef])!

        // When
        let hex = data.base16EncodedString()
        
        // Expect
        XCTAssertEqual(hex, "deadbeef")
    }
    
    func testBase16EncodedString_withEmptyList_shouldReturnEmptyString() {
        // Given
        let data = Data()
        
        // When
        let hex = data.base16EncodedString()
        
        // Expect
        XCTAssertEqual(hex, "")
    }
    
    func testInitWithBase16EncodedString() {
        // Given
        let str = "00112233"
        
        // When
        let data = Data(base16EncodedString: str)
        
        // Expect
        let expectedData = Data(bytesArray: [UInt8(0x00), 0x11, 0x22, 0x33])!
        XCTAssertEqual(data, expectedData)
    }
    
    func testInitWithBase16EncodedString_withUnicodeCharacters() {
        // Given
        let str = "🐥"
        
        // When
        let data = Data(base16EncodedString: str)
        
        // Expect
        XCTAssertEqual(data, Data(bytesArray: []))
    }
    
    // MARK: AES encrypt/decrypt
    
    func fipsAES256KeyAsString() -> String {
        let keyData = Data(base16EncodedString: "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f")!
        return String(data: keyData, encoding: String.Encoding.ascii)!
    }
    
    func fipsData() -> Data {
        let plaintext = "00112233445566778899aabbccddeeff"
        return Data(base16EncodedString: plaintext)!
    }
    
    func testAes256Encrypt_withFIPS197EExample() {
        // Given
        // fips-197 C.3 AES-256 (Nk=8, Nr=14)
        let data = fipsData()
        let output = "8ea2b7ca516745bfeafc49904b496089" // The output given is only the first "block" (vector)
        let key = fipsAES256KeyAsString()
        
        // When
        let crypted = data.aes256Encrypt(key)
        
        // Expect
        XCTAssertEqual(crypted!.subdata(in: Range(uncheckedBounds: (lower: 0, upper: 16))).base16EncodedString(), output)
    }
    
    func testAes256Decrypt_withFIPS197EExample() {
        // Given
        let data = fipsData()
        let key = fipsAES256KeyAsString()
        let crypted = data.aes256Encrypt(key) // rely on encrypt to be OK
        
        // When
        let decrypted = crypted!.aes256Decrypt(key)
        
        // Expect
        XCTAssertEqual(decrypted, data)
    }
    
    // MARK: -
    
    func fipsAES128KeyAsString() -> String {
        let keyData = Data(base16EncodedString: "000102030405060708090a0b0c0d0e0f")!
        return String(data: keyData, encoding: String.Encoding.ascii)!
    }
    
    func testAes128Encrypt_withFIPS197EExample() {
        // Given
        // fips-197 C.3 AES-256 (Nk=8, Nr=14)
        let data = fipsData()
        let output = "69c4e0d86a7b0430d8cdb78070b4c55a" // The output given is only the first "block" (vector)
        let key = fipsAES128KeyAsString()
        
        // When
        let crypted = data.aes128Encrypt(key)
        
        // Expect
        XCTAssertEqual(crypted!.subdata(in: Range(uncheckedBounds: (lower: 0, upper: 16))).base16EncodedString(), output)
    }
    
    func testAes128Decrypt_withFIPS197EExample() {
        // Given
        let data = fipsData()
        let key = fipsAES128KeyAsString()
        let crypted = data.aes128Encrypt(key) // rely on encrypt to be OK
        
        // When
        let decrypted = crypted!.aes128Decrypt(key)
        
        // Expect
        XCTAssertEqual(decrypted, data)
    }
}
