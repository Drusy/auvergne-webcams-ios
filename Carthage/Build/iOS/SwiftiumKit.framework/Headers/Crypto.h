//
//  Crypto.h
//  SwiftiumKit
//
//  Created by Richard Bergoin on 10/03/16.
//  Copyright © 2016 Openium. All rights reserved.
//

extern const int SK_MD5_DIGEST_LENGTH;
extern const int SK_SHA1_DIGEST_LENGTH;
extern const int SK_SHA224_DIGEST_LENGTH;
extern const int SK_SHA256_DIGEST_LENGTH;
extern const int SK_SHA384_DIGEST_LENGTH;
extern const int SK_SHA512_DIGEST_LENGTH;

void sk_crypto_md5(const void *_Nonnull data, unsigned int len, const void *_Nonnull output);
void sk_crypto_sha1(const void *_Nonnull data, unsigned int len, const void *_Nonnull output);
void sk_crypto_sha256(const void *_Nonnull data, unsigned int len, const void *_Nonnull output);
void sk_crypto_sha384(const void *_Nonnull data, unsigned int len, const void *_Nonnull output);
void sk_crypto_sha224(const void *_Nonnull data, unsigned int len, const void *_Nonnull output);
void sk_crypto_sha512(const void *_Nonnull data, unsigned int len, const void *_Nonnull output);

void sk_crypto_hmac_sha1(const void *_Nonnull data, unsigned int dataLength, const void *_Nonnull key, unsigned int keyLength, void *_Nonnull output);

unsigned char *_Nullable sk_crypto_encrypt_aes256(const void *_Nonnull data, unsigned int dataLength, const void *_Nonnull key, unsigned int keyLength, unsigned long *_Nonnull numBytesWritten);
unsigned char *_Nullable sk_crypto_decrypt_aes256(const void *_Nonnull data, unsigned int dataLength, const void *_Nonnull key, unsigned int keyLength, unsigned long *_Nonnull numBytesWritten);
unsigned char *_Nullable sk_crypto_encrypt_aes192(const void *_Nonnull data, unsigned int dataLength, const void *_Nonnull key, unsigned int keyLength, unsigned long *_Nonnull numBytesWritten);
unsigned char *_Nullable sk_crypto_decrypt_aes192(const void *_Nonnull data, unsigned int dataLength, const void *_Nonnull key, unsigned int keyLength, unsigned long *_Nonnull numBytesWritten);
unsigned char *_Nullable sk_crypto_encrypt_aes128(const void *_Nonnull data, unsigned int dataLength, const void *_Nonnull key, unsigned int keyLength, unsigned long *_Nonnull numBytesWritten);
unsigned char *_Nullable sk_crypto_decrypt_aes128(const void *_Nonnull data, unsigned int dataLength, const void *_Nonnull key, unsigned int keyLength, unsigned long *_Nonnull numBytesWritten);
