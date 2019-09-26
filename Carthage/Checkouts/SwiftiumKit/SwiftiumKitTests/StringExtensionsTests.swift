//
//  String+SKAdditionsTests.swift
//  SwiftiumKit
//
//  Created by Richard Bergoin on 10/03/16.
//  Copyright © 2016 Openium. All rights reserved.
//

import XCTest

class StringExtensionsTests: XCTestCase {
    
    let stringToHash = "La chaine à hacher"
    let emptyString = ""
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testMd5() {
        // Given
        
        // When
        let hash = stringToHash.md5
        
        // Expect
        XCTAssertEqual(hash, "bbd5d80e828e166774b4c35076e5b1a6")
    }
    
    func testMd5_withEmptyString() {
        // Given
        
        // When
        let hash = emptyString.md5
        
        // Expect
        XCTAssertEqual(hash, "d41d8cd98f00b204e9800998ecf8427e")
    }
    
    func testSha1() {
        // Given
        
        // When
        let hash = stringToHash.sha1
        
        // Expect
        XCTAssertEqual(hash, "5ba4936fca2ab56482b310ddcf57dc8e87b96b54")
    }
    
    func testSha224() {
        // Given
        
        // When
        let hash = stringToHash.sha224
        
        // Expect
        XCTAssertEqual(hash, "c875a5f938279f1eb0461582757bf101337292c5cab5dde31d25a1f5")
    }
    
    func testSha256() {
        // Given
        
        // When
        let hash = stringToHash.sha256
        
        // Expect
        XCTAssertEqual(hash, "10aad976dbc9336d781821f8b1d87eebf1aff367a6c494646ce4ce7b725b66a4")
    }
    
    func testSha384() {
        // Given
        
        // When
        let hash = stringToHash.sha384
        
        // Expect
        XCTAssertEqual(hash, "15bc03d7299d6edd7ed836bd1821cbab5ddb671c59b7ed6c3dd428e42996bebc47d40a594e97182a4e0fcd7beb6ba663")
    }
    
    func testSha512() {
        // Given
        
        // When
        let hash = stringToHash.sha512
        
        // Expect
        XCTAssertEqual(hash, "4afd5988044494e55a91f26208849ce2221cd50e5b3e363c23f96ebc2f64c0679f5c85325cba71ae8d2df3a523795b2aefb2adb95030a4a4ddf519551e13cc8c")
    }
    
    func testHmacSHA1() {
        // Given
        let passmd5 = "5f4dcc3b5aa765d61d8327deb882cf99";
        let strToSign = "GET\n1391863865\nparam=value&param2=value2\n/path/to/api";
    
        // When
        let shaStr = strToSign.hmacSha1(passmd5)
    
        // Expect
        XCTAssertEqual(shaStr, "18835978a0297b5efca1e44d954f4f0c00b2b903")
    }
    
    // MARK: -
    
    func testIntSubscript() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let thirdChar = someString[3]
        let lastChar = someString[someString.count - 1]
        
        // Expect
        XCTAssertEqual(thirdChar, "d")
        XCTAssertEqual(lastChar, "9")
    }
    
    func testIntSubscript_setCharacter_shouldReplace() {
        // Given
        var someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        let expected = "Af4dcc3b5aa765d61d8327deb882cf9A";
        
        // When
        someString[0] = "A"
        someString[someString.count - 1] = "A"
        
        // Expect
        XCTAssertEqual(someString, expected)
    }
    
    func testIntSubscript_setString_shouldReplaceAndExtendString() {
        // Given
        var someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        let expected = "ABCDEFf4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        someString[0] = "ABCDEF"
        
        // Expect
        XCTAssertEqual(someString, expected)
    }
    
    func testIntSubscript_setString_shouldReplaceAndShorterString() {
        // Given
        var someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        let expected = "f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        someString[0] = ""
        
        // Expect
        XCTAssertEqual(someString, expected)
    }
    
    func testIntSubscript_usingNegativeIndex() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let thirdLastChar = someString[-3]
        let lastChart = someString[-1]
        let firtChar = someString[-someString.count]
        
        // Expect
        XCTAssertEqual(thirdLastChar, "f")
        XCTAssertEqual(lastChart, "9")
        XCTAssertEqual(firtChar, "5")
    }
    
    func testIntSubscript_outOfRange_shouldReturnNil() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let outOfRangeChar = someString[someString.count]
        
        // Expect
        XCTAssertEqual(outOfRangeChar, nil)
    }
    
    func testIntSubscript_usingNegativeIndexOutOfRange_shouldReturnNil() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let outOfRangeChar = someString[-Int.max]
        
        // Expect
        XCTAssertEqual(outOfRangeChar, nil)
    }
    
    func testClosedRangeIntSubscript() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let first4Chars = someString[0...3]
        
        // Expect
        XCTAssertEqual(first4Chars, "5f4d")
    }
    
    func testClosedRangeIntSubscript_usingUpperOutOfRangeIndex_shouldReturnEmptyString() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let emptyString = someString[Int.max...Int.max]
        
        // Expect
        XCTAssertEqual(emptyString, "")
    }
    
    func testClosedRangeIntSubscript_usingSameLowerUpperIndex_shouldReturnEmptyString() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let thirdChar = someString[3...3]
        
        // Expect
        XCTAssertEqual(thirdChar, "d")
    }
    
    func testClosedRangeIntSubscript_outOfRangeUpperAndLower_shouldReturnFullString() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let fullString = someString[-1...someString.count]
        
        // Expect
        XCTAssertEqual(fullString, someString)
    }
    
    func testClosedRangeIntSubscript_outOfRange_shouldBounds() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let index = someString.count - 4
        let last4Chars = someString[index...Int.max]
        
        // Expect
        XCTAssertEqual(last4Chars, "cf99")
    }
    
    func testRangeIntSubscript() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let first3Chars = someString[0..<3]
        
        // Expect
        XCTAssertEqual(first3Chars, "5f4")
    }
    
    func testRangeIntSubscript_outOfRange_shouldBounds() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let index = someString.count - 4
        let last4Chars = someString[index..<Int.max]
        
        // Expect
        XCTAssertEqual(last4Chars, "cf99")
    }
    
    func testRangeIntSubscript_usingUpperOutOfRangeIndex_shouldReturnEmptyString() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let emptyString = someString[Int.max..<Int.max]
        
        // Expect
        XCTAssertEqual(emptyString, "")
    }
    
    func testRangeIntSubscript_usingSameLowerUpperIndex_shouldReturnEmptyString() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let emptyString = someString[4..<4]
        
        // Expect
        XCTAssertEqual(emptyString, "")
    }
    
    func testRangeIntSubscript_outOfRangeUpperAndLower_shouldReturnFullString() {
        // Given
        let someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        let fullString = someString[-1..<someString.count]
        
        // Expect
        XCTAssertEqual(fullString, someString)
    }
    
    // MARK: - Disabled tests
    
    func disabled_testIntSubscript_negativeIndex_shouldRaisePreconditionFailure() {
        // Given
        var someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        let expected = "f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        someString[-1] = ""
        
        // Expect
        XCTAssertEqual(someString, expected)
    }
    
    func disabled_testIntSubscript_outOfRangeIndex_shouldRaisePreconditionFailure() {
        // Given
        var someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        let expected = "f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        someString[someString.count] = ""
        
        // Expect
        XCTAssertEqual(someString, expected)
    }
    
    func disabled_testIntSubscript_nilNewValue_shouldRaisePreconditionFailure() {
        // Given
        var someString = "5f4dcc3b5aa765d61d8327deb882cf99";
        let expected = "f4dcc3b5aa765d61d8327deb882cf99";
        
        // When
        someString[0] = nil
        
        // Expect
        XCTAssertEqual(someString, expected)
    }
    
    // MARK: -
    
    func testFirstLowercased_withEmptyString_shouldReturnEmptyString() {
        // Given
        
        // When
        let result = emptyString.firstLowercased()
        
        // Expect
        XCTAssertEqual(result, "")
    }
    
    func testFirstLowercased_withNonEmptyString_shouldReturnFirstCharLowercased() {
        // Given
        let sut = "Uppercase Words In String"
        
        // When
        let result = sut.firstLowercased()
        
        // Expect
        XCTAssertEqual(result, "uppercase Words In String")
    }
    
    // MARK: -
    
    func testIsEmail_lowercase_valid() {
        // Given
        let email = "fistname.lastname@domain.tld"
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertTrue(isEmail)
    }
    
    func testIsEmail_randomcase_valid() {
        // Given
        let email = "fIsTnAmE.lAsTnAmE@dOmAiN.tLd"
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertTrue(isEmail)
    }
    
    func testIsEmail_no_tld_invalid() {
        // Given
        let email = "fistname.lastname@domain"
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertFalse(isEmail)
    }
    
    func testIsEmail_no_tld_ending_dot_invalid() {
        // Given
        let email = "fistname.lastname@domain."
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertFalse(isEmail)
    }
    
    func testIsEmail_no_at_invalid() {
        // Given
        let email = "fistname.lastnamedomain.tld"
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertFalse(isEmail)
    }
    
    func testIsEmail_no_name_invalid() {
        // Given
        let email = "@domain.tld"
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertFalse(isEmail)
    }
    
    func testIsEmail_whitespace_name_invalid() {
        // Given
        let email = "fistname lastname@domain.tld"
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertFalse(isEmail)
    }
    
    func testIsEmail_whitespace_domain_invalid() {
        // Given
        let email = "fistname.lastname@dom ain.tld"
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertFalse(isEmail)
    }
    
    func testIsEmail_whitespace_tld_invalid() {
        // Given
        let email = "fistname.lastname@domain.t ld"
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertFalse(isEmail)
    }
    
    func testIsEmail_double_dot_name_invalid() {
        // Given
        let email = "fistname..lastname@domain.tld"
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertFalse(isEmail)
    }
    
    func testIsEmail_double_email_valid() {
        // Given
        let email = "fistname.lastname+fistname.lastname@domain.tld"
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertTrue(isEmail)
    }
    
    func testIsEmail_double_plus_email_valid() {
        // Given
        let email = "fistname.lastname+fistname.lastname+2@domain.tld"
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertTrue(isEmail)
    }
    
    func testIsEmail_leading_whitespace_email_invalid() {
        // Given
        let email = " fistname..lastname@domain.tld"
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertFalse(isEmail)
    }
    
    func testIsEmail_trailing_whitespace_email_invalid() {
        // Given
        let email = "fistname..lastname@domain.tld "
        
        // When
        let isEmail = email.isEmail
        
        // Expect
        XCTAssertFalse(isEmail)
    }
}
