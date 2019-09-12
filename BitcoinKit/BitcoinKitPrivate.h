//
//  OpenSSL.h
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


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface _Hash : NSObject

+ (NSData *)sha1:(NSData *)data;
+ (NSData *)sha256:(NSData *)data;
+ (NSData *)sha256ripemd160:(NSData *)data;
+ (NSData *)ripemd160:(NSData *)data;
+ (NSData *)hmacsha512:(NSData *)data key:(NSData *)key;

@end

@interface _Key : NSObject
+ (NSData *)deriveKey:(NSData *)password salt:(NSData *)salt iterations:(NSInteger)iterations keyLength:(NSInteger)keyLength;

@end

@interface _EllipticCurve : NSObject
+ (NSData *)multiplyECPointX:(NSData *)ecPointX andECPointY:(NSData *)ecPointY withScalar:(NSData *)scalar;
+ (NSData *)decodePointOnCurveForCompressedPublicKey:(NSData *)publicKeyCompressed;
@end

@interface _Crypto : NSObject
+ (NSData *)signMessage:(NSData *)message withPrivateKey:(NSData *)privateKey;
+ (BOOL)verifySignature:(NSData *)signature message:(NSData *)message  publicKey:(NSData *)publicKey;
@end
NS_ASSUME_NONNULL_END
