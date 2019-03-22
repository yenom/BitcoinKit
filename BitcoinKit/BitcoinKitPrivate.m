//
//  OpenSSL.m
//
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//  Copyright © 2018 BitcoinKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "BitcoinKitPrivate.h"
#import <openssl/sha.h>
#import <openssl/ripemd.h>
#import <openssl/hmac.h>
#import <openssl/ec.h>
#import <openssl/bn.h>
#import <secp256k1.h>

@implementation _Hash

+ (NSData *)sha1:(NSData *)data {
    NSMutableData *result = [NSMutableData dataWithLength:SHA512_DIGEST_LENGTH];
    SHA1(data.bytes, data.length, result.mutableBytes);
    return result;
}

+ (NSData *)sha256:(NSData *)data {
    NSMutableData *result = [NSMutableData dataWithLength:SHA256_DIGEST_LENGTH];
    SHA256(data.bytes, data.length, result.mutableBytes);
    return result;
}

+ (NSData *)sha256sha256:(NSData *)data {
    return [self sha256:[self sha256:data]];
}

+ (NSData *)ripemd160:(NSData *)data {
    NSMutableData *result = [NSMutableData dataWithLength:RIPEMD160_DIGEST_LENGTH];
    RIPEMD160(data.bytes, data.length, result.mutableBytes);
    return result;
}

+ (NSData *)sha256ripemd160:(NSData *)data {
    return [self ripemd160:[self sha256:data]];
}

+ (NSData *)hmacsha512:(NSData *)data key:(NSData *)key {
    unsigned int length = SHA512_DIGEST_LENGTH;
    NSMutableData *result = [NSMutableData dataWithLength:length];
    HMAC(EVP_sha512(), key.bytes, (int)key.length, data.bytes, data.length, result.mutableBytes, &length);
    return result;
}

@end

@implementation _EllipticCurve
+ (NSData *)multiplyECPointX:(NSData *)ecPointX andECPointY:(NSData *)ecPointY withScalar:(NSData *)scalar {
    BN_CTX *ctx = BN_CTX_new();
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
    
    BIGNUM *multiplication_factor = BN_new();
    BN_bin2bn(scalar.bytes, (int)scalar.length, multiplication_factor);
    
    BIGNUM *point_x = BN_new();
    BN_bin2bn(ecPointX.bytes, (int)ecPointX.length, point_x);
    
    BIGNUM *point_y = BN_new();
    BN_bin2bn(ecPointY.bytes, (int)ecPointY.length, point_y);
    
    EC_POINT *point = EC_POINT_new(group);
    EC_POINT_set_affine_coordinates_GFp(group, point, point_x, point_y, ctx);
    
    EC_POINT *point_result_of_ec_multiplication = EC_POINT_new(group);
    EC_POINT_mul(group, point_result_of_ec_multiplication, nil, point, multiplication_factor, ctx);
    
    NSMutableData *newPointXAndYPrefixedWithByte = [NSMutableData dataWithLength:65];
    BIGNUM *new_point_x_and_y_as_single_bn = BN_new();
    EC_POINT_point2bn(group, point_result_of_ec_multiplication, POINT_CONVERSION_UNCOMPRESSED, new_point_x_and_y_as_single_bn, ctx);
    BN_bn2bin(new_point_x_and_y_as_single_bn, newPointXAndYPrefixedWithByte.mutableBytes);
    
    BN_free(new_point_x_and_y_as_single_bn);
    EC_POINT_free(point_result_of_ec_multiplication);
    EC_POINT_free(point);
    BN_free(multiplication_factor);
    BN_free(point_x);
    BN_free(point_y);
    BN_CTX_free(ctx);
    EC_GROUP_free(group);
    
    return newPointXAndYPrefixedWithByte;
}

+ (NSData *)decodePointOnCurveForCompressedPublicKey:(NSData *)publicKeyCompressed {
    BN_CTX *ctx = BN_CTX_new();
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
    EC_GROUP_set_point_conversion_form(group, POINT_CONVERSION_COMPRESSED);
    EC_POINT *point = EC_POINT_new(group);
    EC_POINT_oct2point(group, point, publicKeyCompressed.bytes, (int)publicKeyCompressed.length, ctx);
    
    NSMutableData *newPointXAndYPrefixedWithByte = [NSMutableData dataWithLength:65];
    BIGNUM *new_point_x_and_y_as_single_bn = BN_new();
    EC_POINT_point2bn(group, point, POINT_CONVERSION_UNCOMPRESSED, new_point_x_and_y_as_single_bn, ctx);
    BN_bn2bin(new_point_x_and_y_as_single_bn, newPointXAndYPrefixedWithByte.mutableBytes);
    
     BN_free(new_point_x_and_y_as_single_bn);
    EC_POINT_free(point);
    BN_CTX_free(ctx);
    EC_GROUP_free(group);
    return newPointXAndYPrefixedWithByte;
}


@end

@implementation _Key

+ (NSData *)deriveKey:(NSData *)password salt:(NSData *)salt iterations:(NSInteger)iterations keyLength:(NSInteger)keyLength {
    NSMutableData *result = [NSMutableData dataWithLength:keyLength];
    PKCS5_PBKDF2_HMAC(password.bytes, (int)password.length, salt.bytes, (int)salt.length, (int)iterations, EVP_sha512(), (int)keyLength, result.mutableBytes);
    return result;
}

@end

@implementation _Crypto

+ (NSData *)signMessage:(NSData *)message withPrivateKey:(NSData *)privateKey {
    secp256k1_context *ctx = secp256k1_context_create(SECP256K1_CONTEXT_SIGN);
    secp256k1_ecdsa_signature signature;
    secp256k1_ecdsa_signature normalizedSignature;
    secp256k1_ecdsa_sign(ctx, &signature, message.bytes, privateKey.bytes, NULL, NULL);
    secp256k1_ecdsa_signature_normalize(ctx, &normalizedSignature, &signature);
    size_t siglen = 74;
    NSMutableData *der = [NSMutableData dataWithLength:siglen];
    secp256k1_ecdsa_signature_serialize_der(ctx, der.mutableBytes, &siglen, &normalizedSignature);
    der.length = siglen;
    secp256k1_context_destroy(ctx);
    return der;
}

+ (BOOL)verifySignature:(NSData *)sigData message:(NSData *)message  publicKey:(NSData *)pubkeyData {
    secp256k1_context *ctx = secp256k1_context_create(SECP256K1_CONTEXT_VERIFY);
    secp256k1_ecdsa_signature signature;
    secp256k1_pubkey pubkey;

    secp256k1_ecdsa_signature_parse_der(ctx, &signature, sigData.bytes, sigData.length);
    if (secp256k1_ec_pubkey_parse(ctx, &pubkey, pubkeyData.bytes, pubkeyData.length) != 1) {
        return FALSE;
    };
    
    if (secp256k1_ecdsa_verify(ctx, &signature, message.bytes, &pubkey) != 1) {
        return FALSE;
    };
    secp256k1_context_destroy(ctx);
    return TRUE;
}
@end
