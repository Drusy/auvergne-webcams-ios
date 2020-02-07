//
//  NSDataExtensions.swift
//  SwiftiumKit
//
//  Created by Richard Bergoin on 14/03/16.
//  Copyright © 2016 Openium. All rights reserved.
//

import Foundation

import CommonCrypto

// MARK: AES encrypt/decrypt

private typealias SKCryptOperationFunction = (Data, String) -> Data?

func sk_crypto_operate(operation: CCOperation, keySize: Int, data: Data, keyData: Data) -> Data? {
    let keyBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: keySize)
    keyBytes.initialize(to: 0)
    keyData.withUnsafeBytes { (bytes) in
        for index in 0..<min(keySize, keyData.count) {
            keyBytes[index] = bytes[index]
        }
    }

    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    let cryptLength = data.count + kCCBlockSizeAES128
    var cryptData = Data(count: cryptLength)

    var numBytesEncrypted = 0

    let cryptStatus = cryptData.withUnsafeMutableBytes { (cryptBytes) -> CCCryptorStatus in
        data.withUnsafeBytes { (dataBytes) -> CCCryptorStatus in
            CCCrypt(operation,
                    CCAlgorithm(kCCAlgorithmAES),
                    CCOptions(kCCOptionPKCS7Padding),
                    keyBytes, keySize,
                    nil,
                    dataBytes.baseAddress, data.count,
                    cryptBytes.baseAddress, cryptLength,
                    &numBytesEncrypted)
        }
    }

    if cryptStatus == kCCSuccess {
        cryptData.count = numBytesEncrypted
        return cryptData
    }

    return nil
}

func sk_crypto_encrypt_aes128(data: Data, key: String) -> Data? {
    return sk_crypto_operate(operation: CCOperation(kCCEncrypt), keySize: kCCKeySizeAES128, data: data, keyData: Data(Array<UInt8>(key.utf8)))
}

func sk_crypto_encrypt_aes192(data: Data, key: String) -> Data? {
    return sk_crypto_operate(operation: CCOperation(kCCEncrypt), keySize: kCCKeySizeAES192, data: data, keyData: Data(Array<UInt8>(key.utf8)))
}

func sk_crypto_encrypt_aes256(data: Data, key: String) -> Data? {
    return sk_crypto_operate(operation: CCOperation(kCCEncrypt), keySize: kCCKeySizeAES256, data: data, keyData: Data(Array<UInt8>(key.utf8)))
}

func sk_crypto_decrypt_aes128(data: Data, key: String) -> Data? {
    return sk_crypto_operate(operation: CCOperation(kCCDecrypt), keySize: kCCKeySizeAES128, data: data, keyData: Data(Array<UInt8>(key.utf8)))
}

func sk_crypto_decrypt_aes192(data: Data, key: String) -> Data? {
    return sk_crypto_operate(operation: CCOperation(kCCDecrypt), keySize: kCCKeySizeAES192, data: data, keyData: Data(Array<UInt8>(key.utf8)))
}

func sk_crypto_decrypt_aes256(data: Data, key: String) -> Data? {
    return sk_crypto_operate(operation: CCOperation(kCCDecrypt), keySize: kCCKeySizeAES256, data: data, keyData: Data(Array<UInt8>(key.utf8)))
}

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
        return operation(self, key)
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
