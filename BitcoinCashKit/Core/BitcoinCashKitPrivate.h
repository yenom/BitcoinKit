//
//  OpenSSL.h
//
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//  Copyright © 2018 BitcoinCashKit developers
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

//@interface BigNumber : NSObject
//
//@property(nonatomic, readonly) uint32_t compact; // compact representation used for the difficulty target
//@property(nonatomic, readonly) uint32_t uint32value;
//@property(nonatomic, readonly) int32_t int32value;
//@property(nonatomic, readonly) uint64_t uint64value;
//@property(nonatomic, readonly) int64_t int64value;
//@property(nonatomic, readonly) NSString* hexString;
//@property(nonatomic, readonly) NSString* decimalString;
//@property(nonatomic, readonly) NSData* signedLittleEndian;
//@property(nonatomic, readonly) NSData* unsignedBigEndian;
//
////// Pointer to an internal BIGNUM value. You should not modify it.
////// To modify, use [[bn mutableCopy] mutableBIGNUM] methods.
////@property(nonatomic, readonly) const BIGNUM* BIGNUM;
//
//@property(nonatomic, readonly) BOOL isZero;
//@property(nonatomic, readonly) BOOL isOne;
//
//
//// BigNumber returns always the same object for these constants.
//// MutableBigNumber returns a new object every time.
//+ (instancetype) zero;        //  0
//+ (instancetype) one;         //  1
//+ (instancetype) negativeOne; // -1
//
//- (id) init;
//- (id) initWithCompact:(uint32_t)compact;
//- (id) initWithUInt32:(uint32_t)value;
//- (id) initWithInt32:(int32_t)value;
//- (id) initWithUInt64:(uint64_t)value;
//- (id) initWithInt64:(int64_t)value;
//- (id) initWithSignedLittleEndian:(NSData*)data;
//- (id) initWithUnsignedBigEndian:(NSData*)data;
//- (id) initWithLittleEndianData:(NSData*)data DEPRECATED_ATTRIBUTE;
//- (id) initWithUnsignedData:(NSData*)data DEPRECATED_ATTRIBUTE;
//
//
////// Initialized with OpenSSL representation of bignum.
////- (id) initWithBIGNUM:(const BIGNUM*)bignum;
//
//// Inits with setString:base:
//- (id) initWithString:(NSString*)string base:(NSUInteger)base;
//
//// Same as initWithString:base:16
//- (id) initWithHexString:(NSString*)hexString DEPRECATED_ATTRIBUTE;
//
//// Same as initWithString:base:10
//- (id) initWithDecimalString:(NSString*)decimalString;
//
//- (NSString*) stringInBase:(NSUInteger)base;
//
//// Re-declared copy and mutableCopy to provide exact return type.
//- (BigNumber*) copy;
////- (BTCMutableBigNumber*) mutableCopy;
//
//
//// Returns MIN(self, other)
//- (BigNumber*) min:(BigNumber*)other;
//
//// Returns MAX(self, other)
//- (BigNumber*) max:(BigNumber*)other;
//
//
//- (BOOL) less:(BigNumber*)other;
//- (BOOL) lessOrEqual:(BigNumber*)other;
//- (BOOL) greater:(BigNumber*)other;
//- (BOOL) greaterOrEqual:(BigNumber*)other;
//
//// Destroys sensitive data and sets the value to 0.
//// It is also called on dealloc.
//// This method is available for both mutable and immutable numbers by design.
//- (void) clear;
//
//// Operators modify the receiver and return self.
//// To create a new instance z = x + y use copy method: z = [[x copy] add:y]
//- (instancetype) add:(BigNumber*)other; // +=
//- (instancetype) add:(BigNumber*)other mod:(BigNumber*)mod;
//- (instancetype) subtract:(BigNumber*)other; // -=
//- (instancetype) subtract:(BigNumber*)other mod:(BigNumber*)mod;
//- (instancetype) multiply:(BigNumber*)other; // *=
//- (instancetype) multiply:(BigNumber*)other mod:(BigNumber*)mod;
//- (instancetype) divide:(BigNumber*)other; // /=
//- (instancetype) mod:(BigNumber*)other; // %=
//- (instancetype) lshift:(unsigned int)shift; // <<=
//- (instancetype) rshift:(unsigned int)shift; // >>=
//- (instancetype) inverseMod:(BigNumber*)mod; // (a^-1) mod n
//- (instancetype) exp:(BigNumber*)power;
//- (instancetype) exp:(BigNumber*)power mod:(BigNumber *)mod;
//
//@end


NS_ASSUME_NONNULL_BEGIN
@interface _Hash : NSObject

+ (NSData *)sha256:(NSData *)data;
+ (NSData *)ripemd160:(NSData *)data;
+ (NSData *)hmacsha512:(NSData *)data key:(NSData *)key;

@end

@interface _Key : NSObject

+ (NSData *)computePublicKeyFromPrivateKey:(NSData *)privateKey compression:(BOOL)compression;
+ (NSData *)deriveKey:(NSData *)password salt:(NSData *)salt iterations:(NSInteger)iterations keyLength:(NSInteger)keyLength;

@end

@interface _HDKey : NSObject

@property (nonatomic, readonly, nullable) NSData *privateKey;
@property (nonatomic, readonly, nullable) NSData *publicKey;
@property (nonatomic, readonly) NSData *chainCode;
@property (nonatomic, readonly) uint8_t depth;
@property (nonatomic, readonly) uint32_t fingerprint;
@property (nonatomic, readonly) uint32_t childIndex;

- (instancetype)initWithPrivateKey:(nullable NSData *)privateKey publicKey:(nullable NSData *)publicKey chainCode:(NSData *)chainCode depth:(uint8_t)depth fingerprint:(uint32_t)fingerprint childIndex:(uint32_t)childIndex;
- (nullable _HDKey *)derivedAtIndex:(uint32_t)childIndex hardened:(BOOL)hardened;

@end

@interface _BigNumber : NSObject
+ (NSData *)Integer2BN:(uint32_t)integer;
+ (uint32_t)BN2Integer:(NSData *)data;

//+ BN_mpi2bn
//+ BN_bn2mpi
//+ BN_bin2bn
//+ BN_bn2bin

@end

NS_ASSUME_NONNULL_END
