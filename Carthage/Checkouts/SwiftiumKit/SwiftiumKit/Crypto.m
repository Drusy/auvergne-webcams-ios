//
//  Crypto.m
//  SwiftiumKit
//
//  Created by Richard Bergoin on 10/03/16.
//  Copyright © 2016 Openium. All rights reserved.
//

#import "Crypto.h"

#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <sys/param.h>

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

const int SK_MD5_DIGEST_LENGTH = CC_MD5_DIGEST_LENGTH;
const int SK_SHA1_DIGEST_LENGTH = CC_SHA1_DIGEST_LENGTH;
const int SK_SHA224_DIGEST_LENGTH = CC_SHA224_DIGEST_LENGTH;
const int SK_SHA256_DIGEST_LENGTH = CC_SHA256_DIGEST_LENGTH;
const int SK_SHA384_DIGEST_LENGTH = CC_SHA384_DIGEST_LENGTH;
const int SK_SHA512_DIGEST_LENGTH = CC_SHA512_DIGEST_LENGTH;

typedef unsigned char * (hashFunctionPointer(const void *, unsigned int, unsigned char *));

void sk_crypto(const void *data, unsigned int len, hashFunctionPointer hashFunction, unsigned int digestLength, const void *output)
{
    hashFunction(data, len, (unsigned char *)output);
}

void sk_crypto_md5(const void *data, unsigned int len, const void *output)
{
    sk_crypto(data, len, CC_MD5, CC_MD5_DIGEST_LENGTH, output);
}

void sk_crypto_sha1(const void *data, unsigned int len, const void *output)
{
    sk_crypto(data, len, CC_SHA1, CC_SHA1_DIGEST_LENGTH, output);
}

void sk_crypto_sha224(const void *data, unsigned int len, const void *output)
{
    sk_crypto(data, len, CC_SHA224, CC_SHA224_DIGEST_LENGTH, output);
}

void sk_crypto_sha256(const void *data, unsigned int len, const void *output)
{
    sk_crypto(data, len, CC_SHA256, CC_SHA256_DIGEST_LENGTH, output);
}

void sk_crypto_sha384(const void *data, unsigned int len, const void *output)
{
    sk_crypto(data, len, CC_SHA384, CC_SHA384_DIGEST_LENGTH, output);
}

void sk_crypto_sha512(const void *data, unsigned int len, const void *output)
{
    sk_crypto(data, len, CC_SHA512, CC_SHA512_DIGEST_LENGTH, output);
}

#pragma mark

void sk_crypto_hmac_sha1(const void *data, unsigned int dataLength, const void *key, unsigned int keyLength, void *output)
{
    CCHmac(kCCHmacAlgSHA1, key, keyLength, data, dataLength, output);
}

#pragma mark

unsigned char *sk_crypto_operate(CCOperation operation, const void *data, unsigned int dataLength, const void *key, unsigned int keyLength, unsigned long *numBytesWritten, unsigned long keySize)
{
    char keyPtr[keySize+1]; // room for terminator (unused)
    bzero(keyPtr, keySize+1); // fill with zeroes (for padding)
    
    memcpy(keyPtr, key, keySize+1);
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    *numBytesWritten = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, keySize,
                                          NULL /* initialization vector (optional) */,
                                          data, dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          numBytesWritten);
    if(cryptStatus == kCCSuccess) {
        return buffer;
    }
    
    free(buffer);
    return NULL;
}

unsigned char *sk_crypto_encrypt_aes256(const void *data, unsigned int dataLength, const void *key, unsigned int keyLength, unsigned long *numBytesWritten)
{
    return sk_crypto_operate(kCCEncrypt, data, dataLength, key, keyLength, numBytesWritten, kCCKeySizeAES256);
}

unsigned char *sk_crypto_decrypt_aes256(const void *data, unsigned int dataLength, const void *key, unsigned int keyLength, unsigned long *numBytesWritten)
{
    return sk_crypto_operate(kCCDecrypt, data, dataLength, key, keyLength, numBytesWritten, kCCKeySizeAES256);
}

unsigned char *sk_crypto_encrypt_aes192(const void *data, unsigned int dataLength, const void *key, unsigned int keyLength, unsigned long *numBytesWritten)
{
    return sk_crypto_operate(kCCEncrypt, data, dataLength, key, keyLength, numBytesWritten, kCCKeySizeAES192);
}

unsigned char *sk_crypto_decrypt_aes192(const void *data, unsigned int dataLength, const void *key, unsigned int keyLength, unsigned long *numBytesWritten)
{
    return sk_crypto_operate(kCCDecrypt, data, dataLength, key, keyLength, numBytesWritten, kCCKeySizeAES192);
}

unsigned char *sk_crypto_encrypt_aes128(const void *data, unsigned int dataLength, const void *key, unsigned int keyLength, unsigned long *numBytesWritten)
{
    return sk_crypto_operate(kCCEncrypt, data, dataLength, key, keyLength, numBytesWritten, kCCKeySizeAES128);
}

unsigned char *sk_crypto_decrypt_aes128(const void *data, unsigned int dataLength, const void *key, unsigned int keyLength, unsigned long *numBytesWritten)
{
    return sk_crypto_operate(kCCDecrypt, data, dataLength, key, keyLength, numBytesWritten, kCCKeySizeAES128);
}
