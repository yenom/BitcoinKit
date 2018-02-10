//
//  OpenSSL.m
//  BitcoinKit
//
//  Created by kishikawakatsumi on 2018/02/09.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

#import "BitcoinKitInternal.h"
#import <openssl/sha.h>
#import <openssl/ripemd.h>
#import <openssl/hmac.h>
#import <openssl/ec.h>

@implementation BitcoinKitInternal

+ (NSData *)sha256:(NSData *)data {
    NSMutableData *result = [NSMutableData dataWithLength:SHA256_DIGEST_LENGTH];
    SHA256(data.bytes, data.length, result.mutableBytes);
    return result;
}

+ (NSData *)ripemd160:(NSData *)data {
    NSMutableData *result = [NSMutableData dataWithLength:RIPEMD160_DIGEST_LENGTH];
    RIPEMD160(data.bytes, data.length, result.mutableBytes);
    return result;
}

+ (NSData *)hmacsha512:(NSData *)data key:(NSData *)key {
    unsigned int length = SHA512_DIGEST_LENGTH;
    NSMutableData *result = [NSMutableData dataWithLength:length];
    HMAC(EVP_sha512(), key.bytes, (int)key.length, data.bytes, data.length, result.mutableBytes, &length);
    return result;
}

+ (NSData *)generatePrivateKey {
    return [NSData data];
}

+ (NSData *)computePublicKeyFromPrivateKey:(NSData *)privateKey compression:(BOOL)compression {
    BN_CTX *ctx = BN_CTX_new();
    EC_KEY *key = EC_KEY_new_by_curve_name(NID_secp256k1);
    const EC_GROUP *group = EC_KEY_get0_group(key);

    BIGNUM *prv = BN_new();
    BN_bin2bn(privateKey.bytes, (int)privateKey.length, prv);

    EC_POINT *pub = EC_POINT_new(group);
    EC_POINT_mul(group, pub, prv, nil, nil, ctx);
    EC_KEY_set_private_key(key, prv);
    EC_KEY_set_public_key(key, pub);

    NSMutableData *result;
    if (compression) {
        EC_KEY_set_conv_form(key, POINT_CONVERSION_COMPRESSED);
        unsigned char *bytes = NULL;
        int length = i2o_ECPublicKey(key, &bytes);
        result = [NSMutableData dataWithBytesNoCopy:bytes length:length];
    } else {
        result = [NSMutableData dataWithLength:65];
        BIGNUM *n = BN_new();
        EC_POINT_point2bn(group, pub, POINT_CONVERSION_UNCOMPRESSED, n, ctx);
        BN_bn2bin(n, result.mutableBytes);
        BN_free(n);
    }

    BN_free(prv);
    EC_POINT_free(pub);
    EC_KEY_free(key);
    BN_CTX_free(ctx);

    return result;
}

+ (NSData *)deriveKey:(NSData *)password salt:(NSData *)salt iterations:(NSInteger)iterations keyLength:(NSInteger)keyLength {
    NSMutableData *result = [NSMutableData dataWithLength:keyLength];
    PKCS5_PBKDF2_HMAC(password.bytes, (int)password.length, salt.bytes, (int)salt.length, (int)iterations, EVP_sha512(), (int)keyLength, result.mutableBytes);
    return result;
}

NSString* BTCHexFromDataWithFormat(NSData* data, const char* format) {
    if (!data) return nil;

    NSUInteger length = data.length;
    if (length == 0) return @"";

    NSMutableData* resultdata = [NSMutableData dataWithLength:length * 2];
    char *dest = resultdata.mutableBytes;
    unsigned const char *src = data.bytes;
    for (int i = 0; i < length; ++i) {
        sprintf(dest + i*2, format, (unsigned int)(src[i]));
    }
    return [[NSString alloc] initWithData:resultdata encoding:NSASCIIStringEncoding];
}

NSString* BTCHexStringFromData(NSData* data) { // deprecated
    return BTCHexFromDataWithFormat(data, "%02x");
}

+ (NSArray *)deriveKey:(nullable NSData *)privateKey publicKey:(NSData *)publicKey chainCode:(NSData *)chainCode atIndex:(uint32_t)index hardened:(BOOL)hardened {
    BN_CTX *ctx = BN_CTX_new();

    NSMutableData *data = [NSMutableData data];
    if (hardened) {
        uint8_t padding = 0;
        [data appendBytes:&padding length:1];
        [data appendData:privateKey];
    } else {
        [data appendData:publicKey];
    }

    uint32_t i = OSSwapHostToBigInt32(hardened ? (0x80000000 | index) : index);
    [data appendBytes:&i length:sizeof(i)];

    NSData *digest = [self hmacsha512:data key:chainCode];
    NSData *prv = [digest subdataWithRange:NSMakeRange(0, 32)];
    NSData *derivedChainCode = [digest subdataWithRange:NSMakeRange(32, 32)];

    BIGNUM *curveOrder = BN_new();
    BN_hex2bn(&curveOrder, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141");

    BIGNUM *factor = BN_new();
    BN_bin2bn(prv.bytes, (int)prv.length, factor);
    // Factor is too big, this derivation is invalid.
    if (BN_cmp(factor, curveOrder) >= 0) {
        return nil;
    }

    NSMutableData *result;
    if (privateKey) {
        BIGNUM *pkNum = BN_new();
        BN_bin2bn(privateKey.bytes, (int)privateKey.length, pkNum);

        BN_mod_add(pkNum, pkNum, factor, curveOrder, ctx);
        // Check for invalid derivation.
        if (BN_is_zero(pkNum)) {
            return nil;
        }

        int numBytes = BN_num_bytes(pkNum);
        result = [NSMutableData dataWithLength:numBytes];
        BN_bn2bin(pkNum, result.mutableBytes);

        BN_free(pkNum);
    } else {
        BIGNUM *pubNum = BN_new();
        BN_bin2bn(publicKey.bytes, (int)publicKey.length, pubNum);
        EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);

        EC_POINT *point = EC_POINT_new(group);
        EC_POINT_bn2point(group, pubNum, point, ctx);
        EC_POINT_mul(group, point, factor, point, BN_value_one(), ctx);
        // Check for invalid derivation.
        if (EC_POINT_is_at_infinity(group, point) == 0) {
            return nil;
        }

        BIGNUM *pointNum = BN_new();
        result = [NSMutableData dataWithLength:33];

        EC_POINT_point2bn(group, point, POINT_CONVERSION_COMPRESSED, pointNum, ctx);
        BN_bn2bin(pointNum, result.mutableBytes);

        BN_free(pointNum);
        EC_POINT_free(point);
        EC_GROUP_free(group);
    }

    BN_free(factor);
    BN_free(curveOrder);
    BN_CTX_free(ctx);

    return @[result, derivedChainCode];
}

@end
