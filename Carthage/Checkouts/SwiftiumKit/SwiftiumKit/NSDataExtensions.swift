//
//  NSDataExtensions.swift
//  SwiftiumKit
//
//  Created by Richard Bergoin on 14/03/16.
//  Copyright © 2016 Openium. All rights reserved.
//

import Foundation

// MARK: AES encrypt/decrypt

private typealias SKCryptOperationFunction = @convention(c) (UnsafeRawPointer, UInt32, UnsafeRawPointer, UInt32, UnsafeMutablePointer<UInt>) -> UnsafeMutablePointer<UInt8>?

private enum EncryptionAlgorithm {
    case aes128, aes192, aes256
    
    var encryptFunction: SKCryptOperationFunction {
        var encryptFunction: SKCryptOperationFunction
        switch self {
        case .aes128: encryptFunction = sk_crypto_encrypt_aes128
        case .aes192: encryptFunction = sk_crypto_encrypt_aes192
        case .aes256: encryptFunction = sk_crypto_encrypt_aes256
        }
        return encryptFunction
    }
    
    var decryptFunction: SKCryptOperationFunction {
        var decryptFunction: SKCryptOperationFunction
        switch self {
        case .aes128: decryptFunction = sk_crypto_decrypt_aes128
        case .aes192: decryptFunction = sk_crypto_decrypt_aes192
        case .aes256: decryptFunction = sk_crypto_decrypt_aes256
        }
        return decryptFunction
    }
}

extension Data {
    
    public init?(base16EncodedString: String) {
        let dataLen = base16EncodedString.count / 2
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: dataLen)
        
        let charactersAsUInt8 = base16EncodedString.map {
            UInt8( strtoul((String($0)), nil, 16))
        }
        
        var strIdx = 0
        for idx in 0..<dataLen {
            let c1 = charactersAsUInt8[strIdx]
            let c2 = charactersAsUInt8[strIdx + 1]
            //bytes[idx]
            bytes[idx] = UInt8((c1<<4) + c2)
            strIdx += 2
        }
        self.init(bytesNoCopy: bytes, count: dataLen, deallocator: .free)
    }
    
    public init?(bytesArray: Array<UInt8>) {
        let dataLen = bytesArray.count
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: dataLen)
        
        var idx = 0
        for byte in bytesArray {
            bytes[idx] = byte
            idx += 1
        }
        self.init(bytesNoCopy: bytes, count: dataLen, deallocator: .free)
    }
    
    public func base16EncodedString() -> String {
        var hex = String()
        let bytes = (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.count)
        for idx in 0..<self.count {
            let value: UInt8 = UnsafePointer<UInt8>(bytes)[idx]
            hex.append(value.toHexaString())
        }
        return hex
    }
    
    fileprivate func aesOperation(_ key: String, operation: SKCryptOperationFunction) -> Data? {
        let lengthPtr = UnsafeMutablePointer<UInt>.allocate(capacity: 1)
        defer { lengthPtr.deallocate() }
        
        if let buffer = operation((self as NSData).bytes, UInt32(self.count), Array<UInt8>(key.utf8), UInt32(key.utf8.count), lengthPtr) {
            let length: Int = Int(lengthPtr[0])
            return Data(bytesNoCopy: UnsafeMutablePointer<UInt8>(buffer), count: length, deallocator: .free)
        }

        return nil
    }
    
    /// Encrypts an Array\<AESEncryptable> using provided `key` (utf8 data) with AES256
    /// :returns: Bytes array of encrypted data
    public func aes256Encrypt(_ key: String) -> Data? {
        return aesOperation(key, operation: EncryptionAlgorithm.aes256.encryptFunction)
    }
    
    /// Decrypts an Array\<AESEncryptable> using provided `key` (utf8 data) with AES256
    /// :returns: Bytes array of decrypted data
    public func aes256Decrypt(_ key: String) -> Data? {
        return aesOperation(key, operation: EncryptionAlgorithm.aes256.decryptFunction)
    }
    
    /// Encrypts an Array\<AESEncryptable> using provided `key` (utf8 data) with AES192
    /// :returns: Bytes array of encrypted data
    public func aes192Encrypt(_ key: String) -> Data? {
        return aesOperation(key, operation: EncryptionAlgorithm.aes192.encryptFunction)
    }
    
    /// Decrypts an Array\<AESEncryptable> using provided `key` (utf8 data) with AES192
    /// :returns: Bytes array of decrypted data
    public func aes192Decrypt(_ key: String) -> Data? {
        return aesOperation(key, operation: EncryptionAlgorithm.aes192.decryptFunction)
    }
    
    /// Encrypts an Array\<AESEncryptable> using provided `key` (utf8 data) with AES128
    /// :returns: Bytes array of encrypted data
    public func aes128Encrypt(_ key: String) -> Data? {
        return aesOperation(key, operation: EncryptionAlgorithm.aes128.encryptFunction)
    }
    
    /// Decrypts an Array\<AESEncryptable> using provided `key` (utf8 data) with AES128
    /// :returns: Bytes array of decrypted data
    public func aes128Decrypt(_ key: String) -> Data? {
        return aesOperation(key, operation: EncryptionAlgorithm.aes128.decryptFunction)
    }
}
