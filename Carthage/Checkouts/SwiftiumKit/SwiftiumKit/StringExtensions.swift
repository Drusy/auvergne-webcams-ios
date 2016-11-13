//
//  String+SKAdditions.swift
//  SwiftiumKit
//
//  Created by Richard Bergoin on 10/03/16.
//  Copyright © 2016 Openium. All rights reserved.
//

import Foundation

// MARK: Hashes

private typealias SKCryptoFunctionPointer = (UnsafeRawPointer, UInt32, UnsafeRawPointer) -> Void

private enum CryptoAlgorithm {
    case md5, sha1, sha224, sha256, sha384, sha512
    
    var cryptoFunction: SKCryptoFunctionPointer {
        var result: SKCryptoFunctionPointer
        switch self {
        case .md5: result = sk_crypto_md5
        case .sha1: result = sk_crypto_sha1
        case .sha224: result = sk_crypto_sha224
        case .sha256: result = sk_crypto_sha256
        case .sha384: result = sk_crypto_sha384
        case .sha512: result = sk_crypto_sha512
        }
        return result
    }
    
    var digestLength: Int {
        var length: Int
        switch self {
        case .md5: length = Int(SK_MD5_DIGEST_LENGTH)
        case .sha1: length = Int(SK_SHA1_DIGEST_LENGTH)
        case .sha224: length = Int(SK_SHA224_DIGEST_LENGTH)
        case .sha256: length = Int(SK_SHA256_DIGEST_LENGTH)
        case .sha384: length = Int(SK_SHA384_DIGEST_LENGTH)
        case .sha512: length = Int(SK_SHA512_DIGEST_LENGTH)
        }
        return length
    }
}

extension String.UTF8View {
    
    var md5: Data {
        return self.hashUsingAlgorithm(.md5)
    }
    
    var sha1: Data {
        return self.hashUsingAlgorithm(.sha1)
    }
    
    var sha224: Data {
        return self.hashUsingAlgorithm(.sha224)
    }

    var sha256: Data {
        return self.hashUsingAlgorithm(.sha256)
    }

    var sha384: Data {
        return self.hashUsingAlgorithm(.sha384)
    }

    var sha512: Data {
        return self.hashUsingAlgorithm(.sha512)
    }
    
    fileprivate func hashUsingAlgorithm(_ algorithm: CryptoAlgorithm) -> Data {
        let cryptoFunction = algorithm.cryptoFunction
        let length = algorithm.digestLength
        return self.hash(cryptoFunction, length: length)
    }
    
    fileprivate func hash(_ cryptoFunction: SKCryptoFunctionPointer, length: Int) -> Data {
        let hashBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        //defer { hashBytes.dealloc(length) }

        cryptoFunction(Array<UInt8>(self), UInt32(self.count), hashBytes)

        return Data(bytesNoCopy: UnsafeMutablePointer<UInt8>(hashBytes), count: length, deallocator: .free)
    }
}

extension String {

    public var md5HashData: Data {
        return self.utf8.md5
    }
    
    /// Converts string UTF8 data to MD5 checksum (lowercase hexadecimal)
    /// :returns: lowercase hexadecimal string containing MD5 hash
    public var md5: String {
        return self.md5HashData.base16EncodedString()
    }

    public var sha1HashData: Data {
        return self.utf8.sha1
    }
    
    /// Converts string UTF8 data to SHA1 checksum (lowercase hexadecimal)
    /// :returns: lowercase hexadecimal string containing SHA1 hash
    public var sha1: String {
        return self.sha1HashData.base16EncodedString()
    }
    
    public var sha224HashData: Data {
        return self.utf8.sha224
    }
    
    /// Converts string UTF8 data to SHA224 checksum (lowercase hexadecimal)
    /// :returns: lowercase hexadecimal string containing SHA224 hash
    public var sha224: String {
        return self.sha224HashData.base16EncodedString()
    }
    
    public var sha256HashData: Data {
        return self.utf8.sha256
    }
    
    /// Converts string UTF8 data to SHA256 checksum (lowercase hexadecimal)
    /// :returns: lowercase hexadecimal string containing SHA256 hash
    public var sha256: String {
        return self.sha256HashData.base16EncodedString()
    }
    
    public var sha384HashData: Data {
        return self.utf8.sha384
    }
    
    /// Converts string UTF8 data to SHA384 checksum (lowercase hexadecimal)
    /// :returns: lowercase hexadecimal string containing SHA384 hash
    public var sha384: String {
        return self.sha384HashData.base16EncodedString()
    }
    
    public var sha512HashData: Data {
        return self.utf8.sha512
    }
    
    /// Converts string UTF8 data to SHA512 checksum (lowercase hexadecimal)
    /// :returns: lowercase hexadecimal string containing SHA512 hash
    public var sha512: String {
        return self.sha512HashData.base16EncodedString()
    }
    
    
    public func hmacSha1(_ key: String) -> String {
        let keyData = Array<UInt8>(key.utf8)
        let length = Int(20)
        
        let hashBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        //defer { hashBytes.dealloc(length) }
        
        sk_crypto_hmac_sha1(Array<UInt8>(self.utf8), UInt32(self.utf8.count), keyData, UInt32(key.utf8.count), hashBytes)
        let data = Data(bytesNoCopy: UnsafeMutablePointer<UInt8>(hashBytes), count: length, deallocator: .free)
        
        return data.base16EncodedString()
    }
    
    /**
     Int subscript to String
     
     Usage example :
     ````
     var somestring = "some string"
     
     let substring = somestring[3]
     let substringNegativeIndex = somestring[-1]
     ````
     
     - Parameter i: index of the string
     - Returns: a String containing the character at position i or nil if index is out of string bounds
     */
    public subscript(i: Int) -> String? {
        get {
            guard i >= -characters.count && i < characters.count else { return nil }
            
            let charIndex: Index
            
            if i >= 0 {
                charIndex = index(startIndex, offsetBy: i)
            } else {
                charIndex = index(startIndex, offsetBy: characters.count + i)
            }
            
            return String(self[charIndex])
        }
        
        set(newValue) {
            guard i >= 0 && i < characters.count else {
                preconditionFailure("String subscript can only be used if the condition (index >= 0 && index < characters.count) is fulfilled")
            }
            guard newValue != nil else {
                preconditionFailure("String replacement should not be nil")
            }

            let lowerIndex = index(startIndex, offsetBy: i, limitedBy: endIndex)!
            let upperIndex = index(startIndex, offsetBy: i + 1, limitedBy: endIndex)!
            let range = Range<String.Index>(uncheckedBounds: (lower: lowerIndex, upper: upperIndex))
            
            if !range.isEmpty {
                self = self.replacingCharacters(in: range, with: newValue!)
            }
        }
    }
    
    /**
     Int closed range subscript to String
     
     Usage example :
     ````
     let somestring = "some string"
     let substring = somestring[0..3]
     ````
     - Parameter range: a closed range of the string
     - Returns: a substring containing the characters in the specified closed range
     */
    public subscript(range: ClosedRange<Int>) -> String {
        let maxLowerBound = max(0, range.lowerBound)
        let maxSupportedLowerOffset = maxLowerBound
        let maxSupportedUpperOffset = range.upperBound - maxLowerBound + 1
        
        let lowerIndex = index(startIndex, offsetBy: maxSupportedLowerOffset, limitedBy: endIndex) ?? endIndex
        let upperIndex = index(lowerIndex, offsetBy: maxSupportedUpperOffset, limitedBy: endIndex) ?? endIndex
        
        return substring(with: lowerIndex..<upperIndex)
    }
    
    /**
     Int range subscript to String
     
     Usage example :
     ````
     let somestring = "some string"
     let substring = somestring[0..<3]
     ````
     - Parameter range: a range of the string
     - Returns: a substring containing the characters in the specified range
     */
    public subscript(range: Range<Int>) -> String {
        let maxLowerBound = max(0, range.lowerBound)
        let maxSupportedLowerOffset = maxLowerBound
        let maxSupportedUpperOffset = range.upperBound - maxLowerBound
        
        let lowerIndex = index(startIndex, offsetBy: maxSupportedLowerOffset, limitedBy: endIndex) ?? endIndex
        let upperIndex = index(lowerIndex, offsetBy: maxSupportedUpperOffset, limitedBy: endIndex) ?? endIndex
        
        return substring(with: lowerIndex..<upperIndex)
    }
}

extension String {
    public func firstLowercased() -> String {
        var firstLowercased = self
        if let firstCharLowercased = self[0]?.lowercased() {
            firstLowercased[0] = firstCharLowercased
        }
        return firstLowercased
    }
}
