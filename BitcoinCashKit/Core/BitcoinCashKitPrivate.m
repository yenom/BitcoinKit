//
//  OpenSSL.m
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

#import "BitcoinCashKitPrivate.h"
#import <openssl/sha.h>
#import <openssl/ripemd.h>
#import <openssl/hmac.h>
#import <openssl/ec.h>
#import <openssl/bn.h>


//void BTCReverseBytesLength(void* bytes, NSUInteger length) {
//    // K&R
//    if (length <= 1) return;
//    unsigned char* buf = bytes;
//    unsigned char byte;
//    NSUInteger i, j;
//    for (i = 0, j = length - 1; i < j; i++, j--) {
//        byte = buf[i];
//        buf[i] = buf[j];
//        buf[j] = byte;
//    }
//}
//
//// Reverses byte order in the internal buffer of mutable data object.
//void BTCDataReverse(NSMutableData* self) {
//    BTCReverseBytesLength(self.mutableBytes, self.length);
//}
//
//#define BigNumberCompare(a, b) (BN_cmp(&(a->_bignum), &(b->_bignum)))
//
//@implementation BigNumber {
//    @package
//    BIGNUM _bignum;
//    
//    // Used as a guard in case a private setter is called on immutable instance after initialization.
//    BOOL _immutable;
//}
//
//@dynamic compact;
//@dynamic uint32value;
//@dynamic int32value;
//@dynamic uint64value;
//@dynamic int64value;
//@dynamic hexString;
//@dynamic decimalString;
//@dynamic signedLittleEndian;
//@dynamic unsignedBigEndian;
//
//+ (instancetype) zero {
//    static BigNumber* bn = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        bn = [[self alloc] init];
//        BN_zero(&(bn->_bignum));
//    });
//    return bn;
//}
//
//+ (instancetype) one {
//    static BigNumber* bn = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        bn = [[self alloc] init];
//        BN_one(&(bn->_bignum));
//    });
//    return bn;
//}
//
//+ (instancetype) negativeOne {
//    static BigNumber* bn = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        bn = [[self alloc] initWithInt32:-1];
//    });
//    return bn;
//}
//
//- (id) init {
//    if (self = [super init]) {
//        BN_init(&_bignum);
//    }
//    return self;
//}
//
//- (void) dealloc {
//    BN_clear_free(&_bignum);
//}
//
//- (void) clear {
//    BN_clear(&_bignum);
//}
//
//- (void) throwIfImmutable {
//    if (_immutable) {
//        @throw [NSException exceptionWithName:@"Immutable BigNumber is modified" reason:@"" userInfo:nil];
//    }
//}
//
//// Since we use private setters in the init* methods,
//- (id) initWithCompact:(uint32_t)value {
//    if (self = [self init]) self.compact = value;
//    _immutable = YES;
//    return self;
//}
//- (id) initWithUInt32:(uint32_t)value {
//    if (self = [self init]) self.uint32value = value;
//    _immutable = YES;
//    return self;
//}
//- (id) initWithInt32:(int32_t)value {
//    if (self = [self init]) self.int32value = value;
//    _immutable = YES;
//    return self;
//}
//- (id) initWithUInt64:(uint64_t)value {
//    if (self = [self init]) self.uint64value = value;
//    _immutable = YES;
//    return self;
//}
//- (id) initWithInt64:(int64_t)value {
//    if (self = [self init]) self.int64value = value;
//    _immutable = YES;
//    return self;
//}
//- (id) initWithSignedLittleEndian:(NSData *)data {
//    if (!data) return nil;
//    if (self = [self init]) self.signedLittleEndian = data;
//    _immutable = YES;
//    return self;
//}
//- (id) initWithUnsignedBigEndian:(NSData *)data {
//    if (!data) return nil;
//    if (self = [self init]) self.unsignedBigEndian = data;
//    _immutable = YES;
//    return self;
//}
//- (id) initWithLittleEndianData:(NSData*)data { // deprecated
//    if (!data) return nil;
//    if (self = [self init]) self.signedLittleEndian = data;
//    _immutable = YES;
//    return self;
//}
//- (id) initWithUnsignedData:(NSData *)data { // deprecated
//    if (!data) return nil;
//    if (self = [self init]) self.unsignedBigEndian = data;
//    _immutable = YES;
//    return self;
//}
//- (id) initWithString:(NSString*)string base:(NSUInteger)base {
//    if (!string) return nil;
//    if (self = [self init]) [self setString:string base:base];
//    _immutable = YES;
//    return self;
//}
//
//- (id) initWithHexString:(NSString*)hexString {
//    return [self initWithString:hexString base:16];
//}
//
//- (id) initWithDecimalString:(NSString*)decimalString {
//    return [self initWithString:decimalString base:10];
//}
//
//- (id) initWithBIGNUM:(const BIGNUM*)otherBIGNUM {
//    if (self = [self init]) {
//        BN_copy(&_bignum, otherBIGNUM);
//    }
//    return self;
//}
//
//- (const BIGNUM*) BIGNUM {
//    return &_bignum;
//}
//
//- (BOOL) isZero {
//    return BN_is_zero(&_bignum);
//}
//
//- (BOOL) isOne {
//    return BN_is_one(&_bignum);
//}
//
//
////#pragma mark - NSObject
////
////
////
////- (BigNumber*) copy {
////    return [self copyWithZone:nil];
////}
////
////- (BTCMutableBigNumber*) mutableCopy {
////    return [self mutableCopyWithZone:nil];
////}
////
////- (BigNumber*) copyWithZone:(NSZone *)zone {
////    BigNumber* to = [[BigNumber alloc] init];
////    if (BN_copy(&(to->_bignum), &_bignum)) {
////        return to;
////    }
////    return nil;
////}
////
////- (BTCMutableBigNumber*) mutableCopyWithZone:(NSZone *)zone {
////    BTCMutableBigNumber* to = [[BTCMutableBigNumber alloc] init];
////    if (BN_copy(&(to->_bignum), &_bignum)) {
////        return to;
////    }
////    return nil;
////}
////
////
////- (BOOL) isEqual:(BigNumber*)other {
////    if (![other isKindOfClass:[BigNumber class]]) return NO;
////    return BigNumberCompare(self, other) == NSOrderedSame;
////}
////
////- (NSComparisonResult)compare:(BigNumber *)other {
////    return BigNumberCompare(self, other);
////}
////
//- (NSString*) description {
//    return [NSString stringWithFormat:@"<%@:0x%p 0x%@ (%@)>", [self class], self, [self stringInBase:16], [self stringInBase:10]];
//}
//
//#pragma mark - Conversion
//
//- (NSString*) hexString {
//    return [self stringInBase:16];
//}
//
//- (void) setHexString:(NSString *)hexString {
//    [self throwIfImmutable];
//    [self setString:hexString base:16];
//}
//
//- (NSString*) decimalString {
//    return [self stringInBase:10];
//}
//
//- (void) setDecimalString:(NSString *)decimalString {
//    [self throwIfImmutable];
//    [self setString:decimalString base:10];
//}
//
//- (void) setString:(NSString*)string base:(NSUInteger)base {
//    [self throwIfImmutable];
//    if (base > 36 || base < 2) return;
//    
//    BN_set_word(&_bignum, 0);
//    
//    if (string.length == 0) return;
//    
//    const unsigned char *psz = (const unsigned char*)[string cStringUsingEncoding:NSASCIIStringEncoding];
//    
//    while (isspace(*psz)) psz++;
//    
//    bool isNegative = false;
//    if (*psz == '-') {
//        isNegative = true;
//        psz++;
//    }
//    
//    // Strip 0x from a 16-base string and 0b from a binary string.
//    // String is null-terminated, so it's safe to check for [1] if [0] is not null
//    if (base == 16 && psz[0] == '0' && tolower(psz[1]) == 'x') psz += 2;
//    if (base == 2  && psz[0] == '0' && tolower(psz[1]) == 'b') psz += 2;
//    
//    while (isspace(*psz)) psz++;
//    
//    static const signed char digits[256] = {
//        //  0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
//        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
//        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
//        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
//        0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  0,  0,  0,  0,  0,  0,
//        //  @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O
//        0, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
//        //  P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _
//        25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,  0,  0,  0,  0,  0,
//        //  `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o
//        0, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
//        //  p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~   del
//        25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,  0,  0,  0,  0,  0,
//        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
//        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
//        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
//        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
//        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
//        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
//        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
//        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
//    };
//    
//    BN_CTX* pctx = NULL;
//    BIGNUM bnBase; BN_init(&bnBase); BN_set_word(&bnBase, (BN_ULONG)base);
//    
//    while (1) {
//        unsigned char c = (unsigned char)*psz++;
//        if (c == 0) break; // break when null-terminator is hit
//        
//        if (c != 0x20) { // skip space
//            
//            int n = digits[c];
//            if (n == 0 && c != 0x30) break; // discard characters outside the 36-char range
//            if (n >= base) break; // discard character outside the base range.
//            
//            if (base == 16) {
//                BN_lshift(&_bignum, &_bignum, 4);
//            } else if (base == 8) {
//                BN_lshift(&_bignum, &_bignum, 3);
//            } else if (base == 4) {
//                BN_lshift(&_bignum, &_bignum, 2);
//            } else if (base == 2) {
//                BN_lshift(&_bignum, &_bignum, 1);
//            } else if (base == 32) {
//                BN_lshift(&_bignum, &_bignum, 5);
//            } else {
//                if (!pctx) pctx = BN_CTX_new();
//                BN_mul(&_bignum, &_bignum, &bnBase, pctx);
//            }
//            
//            BN_add_word(&_bignum, n);
//        }
//    }
//    
//    if (isNegative) {
//        BN_set_negative(&_bignum, 1);
//    }
//    
//    BN_free(&bnBase);
//    if (pctx) BN_CTX_free(pctx);
//}
//
//- (NSString*) stringInBase:(NSUInteger)base {
//    if (base > 36 || base < 2) return nil;
//    
//    NSMutableData* resultData = nil;
//    
//    BN_CTX* pctx = BN_CTX_new();
//    BIGNUM bnBase; BN_init(&bnBase); BN_set_word(&bnBase, (BN_ULONG)base);
//    BIGNUM bn0;    BN_init(&bn0);    BN_zero(&bn0);
//    BIGNUM bn;     BN_init(&bn);     BN_copy(&bn, &_bignum);
//    
//    BN_set_negative(&bn, false);
//    
//    BIGNUM dv;  BN_init(&dv);
//    BIGNUM rem; BN_init(&rem);
//    
//    if (BN_cmp(&bn, &bn0) == 0) {
//        resultData = [NSMutableData dataWithBytes:"0" length:1];
//    } else {
//        while (BN_cmp(&bn, &bn0) > 0) {
//            if (!BN_div(&dv, &rem, &bn, &bnBase, pctx)) {
//                NSLog(@"BigNumber: stringInBase failed to BN_div");
//                break;
//            }
//            BN_copy(&bn, &dv);
//            BN_ULONG c = BN_get_word(&rem);
//            
//            if (!resultData) resultData = [NSMutableData data];
//            
//            // 36 characters:   0123456789 123456789 123456789 12345
//            unsigned char ch = "0123456789abcdefghijklmnopqrstuvwxyz"[c];
//            
//            [resultData replaceBytesInRange:NSMakeRange(0, 0) withBytes:&ch length:1];
//        }
//        if (resultData && BN_is_negative(&_bignum)) {
//            unsigned char ch = '-';
//            [resultData replaceBytesInRange:NSMakeRange(0, 0) withBytes:&ch length:1];
//        }
//    }
//    
//    BN_clear_free(&dv);
//    BN_clear_free(&rem);
//    BN_clear_free(&bn);
//    BN_free(&bn0);
//    BN_free(&bnBase);
//    BN_CTX_free(pctx);
//    return resultData ? [[NSString alloc] initWithData:resultData encoding:NSASCIIStringEncoding] : nil;
//}
//
//
//// [0...7] : exponent of base256 ("number of bytes of N")
//// [8] : sign of N
//// [9...31] : mantissa
//
//// The "compact" format is a representation of a whole
//// number N using an unsigned 32bit number similar to a
//// floating point format.
//// The most significant 8 bits are the unsigned exponent of base 256.
//// This exponent can be thought of as "number of bytes of N".
//// The lower 23 bits are the mantissa.
//// Bit number 24 (0x800000) represents the sign of N.
//// N = (-1^sign) * mantissa * 256^(exponent-3)
////
//// Satoshi's original implementation used BN_bn2mpi() and BN_mpi2bn().
//// MPI uses the most significant bit of the first byte as sign.
//// Thus 0x1234560000 is compact (0x05123456) -> 5 + 0x123456 -> 0x123456 + 0000 [(5-3)*2]
//// and  0xc0de000000 is compact (0x0600c0de) -> 6 + 0xc0de -> 0xc0de + 000000 [(6-3)*2]
//// (0x05c0de00) would be -0x40de000000 -> 5 + sign + 0x40de00 -> 0x40de00 + 0000 [(5-3)*2]
////
//// Bitcoin only uses this "compact" format for encoding difficulty
//// targets, which are unsigned 256bit quantities.  Thus, all the
//// complexities of the sign bit and using base 256 are probably an
//// implementation accident.
////
//// This implementation directly uses shifts instead of going
//// through an intermediate MPI representation.
//- (uint32_t) compact {
//    uint32_t size = BN_num_bytes(&_bignum);
//    uint32_t result = 0;
//    if (size <= 3) {
//        result = (uint32_t)(BN_get_word(&_bignum) << 8*(3-size));
//    } else {
//        BIGNUM bn;
//        BN_init(&bn);
//        BN_rshift(&bn, &_bignum, 8*(size-3));
//        result = (uint32_t)BN_get_word(&bn);
//    }
//    // The 0x00800000 bit denotes the sign.
//    // Thus, if it is already set, divide the mantissa by 256 and increase the exponent.
//    if (result & 0x00800000) {
//        result >>= 8;
//        size++;
//    }
//    result |= size << 24;
//    result |= (BN_is_negative(&_bignum) ? 0x00800000 : 0);
//    return result;
//}
//
//- (void) setCompact:(uint32_t)value {
//    [self throwIfImmutable];
//    unsigned int size = value >> 24;
//    bool isNegative   = (value & 0x00800000) != 0;
//    unsigned int word = value & 0x007fffff;
//    if (size <= 3) {
//        word >>= 8*(3-size);
//        BN_set_word(&_bignum, word);
//    } else {
//        BN_set_word(&_bignum, word);
//        BN_lshift(&_bignum, &_bignum, 8*(size-3));
//    }
//    BN_set_negative(&_bignum, isNegative);
//}
//
//- (uint32_t) uint32value {
//    return (uint32_t)BN_get_word(&_bignum);
//}
//
//- (void) setUint32value:(uint32_t)value {
//    [self throwIfImmutable];
//    BN_set_word(&_bignum, value);
//}
//
//- (int32_t) int32value {
//    uint32_t value = [self uint32value];
//    if (!BN_is_negative(&_bignum)) {
//        if (value > INT32_MAX)
//            return INT32_MAX;
//        else
//            return value;
//    } else {
//        if (value > INT32_MAX)
//            return INT32_MIN;
//        else
//            return -value;
//    }
//}
//
//- (void) setInt32value:(int32_t)value {
//    [self throwIfImmutable];
//    if (value >= 0) {
//        self.uint32value = value;
//    } else {
//        self.int64value = value;
//    }
//}
//
//- (uint64_t) uint64value {
//    return (uint64_t)BN_get_word(&_bignum);
//}
//
//- (int64_t) int64value {
//    return (int64_t)BN_get_word(&_bignum);
//}
//
//- (void) setUint64value:(uint64_t)value {
//    [self throwIfImmutable];
//    [self setUint64valuePrivate:value negative:NO];
//}
//
//- (void) setInt64value:(int64_t)value {
//    [self throwIfImmutable];
//    bool isNegative = NO;
//    uint64_t uintValue;
//    if (value < 0) {
//        // Since the minimum signed integer cannot be represented as
//        // positive so long as its type is signed, and it's not well-defined
//        // what happens if you make it unsigned before negating it, we
//        // instead increment the negative integer by 1, convert it, then
//        // increment the (now positive) unsigned integer by 1 to compensate.
//        uintValue = -(value + 1);
//        ++uintValue;
//        isNegative = YES;
//    } else {
//        uintValue = value;
//    }
//    
//    [self setUint64valuePrivate:uintValue negative:isNegative];
//}
//
//- (void) setUint64valuePrivate:(uint64_t)value negative:(BOOL)isNegative {
//    // Numbers are represented in OpenSSL using the MPI format. 4 byte length.
//    unsigned char rawMPI[sizeof(value) + 6];
//    unsigned char* currentByte = &rawMPI[4];
//    BOOL leadingZeros = YES;
//    for (int i = 0; i < 8; ++i) {
//        uint8_t c = (value >> 56) & 0xff;
//        value <<= 8;
//        if (leadingZeros) {
//            if (c == 0) continue; // Skip beginning zeros
//            
//            if (c & 0x80) {
//                *currentByte = (isNegative ? 0x80 : 0);
//                ++currentByte;
//            } else if (isNegative) {
//                c |= 0x80;
//            }
//            leadingZeros = false;
//        }
//        *currentByte = c;
//        ++currentByte;
//    }
//    unsigned long size = currentByte - (rawMPI + 4);
//    rawMPI[0] = (size >> 24) & 0xff;
//    rawMPI[1] = (size >> 16) & 0xff;
//    rawMPI[2] = (size >> 8) & 0xff;
//    rawMPI[3] = (size) & 0xff;
//    BN_mpi2bn(rawMPI, (int)(currentByte - rawMPI), &_bignum);
//}
//
//- (NSData*) signedLittleEndian {
//    size_t size = BN_bn2mpi(&_bignum, NULL);
//    if (size <= 4) {
//        return [NSData data];
//    }
//    NSMutableData* data = [NSMutableData dataWithLength:size];
//    BN_bn2mpi(&_bignum, data.mutableBytes);
//    [data replaceBytesInRange:NSMakeRange(0, 4) withBytes:NULL length:0];
//     BTCDataReverse(data);
//    return data;
//}
//
//- (void) setSignedLittleEndian:(NSData *)data {
//    [self throwIfImmutable];
//    NSUInteger size = data.length;
//    NSMutableData* mdata = [data mutableCopy];
//    // Reverse to convert to OpenSSL bignum endianess
//    BTCDataReverse(mdata); //TODO:@@@@@@@@@@@
//    // BIGNUM's byte stream format expects 4 bytes of
//    // big endian size data info at the front
//    [mdata replaceBytesInRange:NSMakeRange(0, 0) withBytes:"\0\0\0\0" length:4];
//    unsigned char* bytes = mdata.mutableBytes;
//    bytes[0] = (size >> 24) & 0xff;
//    bytes[1] = (size >> 16) & 0xff;
//    bytes[2] = (size >> 8) & 0xff;
//    bytes[3] = (size >> 0) & 0xff;
//    
//    BN_mpi2bn(bytes, (int)mdata.length, &_bignum);
//}
//
//- (NSData*) unsignedBigEndian {
//    int num_bytes = BN_num_bytes(&_bignum);
//    NSMutableData* data = [[NSMutableData alloc] initWithLength:32]; // zeroed data
//    int copied_bytes = BN_bn2bin(&_bignum, &data.mutableBytes[32 - num_bytes]); // fill the tail of the data so it's zero-padded to the left
//    if (copied_bytes != num_bytes) return nil;
//    return data;
//}
//
//- (void) setUnsignedBigEndian:(NSData *)data {
//    [self throwIfImmutable];
//    if (!data) return;
//    if (!BN_bin2bn(data.bytes, (int)data.length, &_bignum)) {
//        return;
//    }
//}
//
//#pragma mark - NSObject
//- (BigNumber*) copy {
//    return [self copyWithZone:nil];
//}
//
////- (MutableBigNumber*) mutableCopy {
////    return [self mutableCopyWithZone:nil];
////}
//
//- (BigNumber*) copyWithZone:(NSZone *)zone {
//    BigNumber* to = [[BigNumber alloc] init];
//    if (BN_copy(&(to->_bignum), &_bignum)) {
//        return to;
//    }
//    return nil;
//}
//
////- (BTCMutableBigNumber*) mutableCopyWithZone:(NSZone *)zone {
////    BTCMutableBigNumber* to = [[BTCMutableBigNumber alloc] init];
////    if (BN_copy(&(to->_bignum), &_bignum)) {
////        return to;
////    }
////    return nil;
////}
//
//- (BOOL) isEqual:( BigNumber*)other {
//    if (![other isKindOfClass:[BigNumber class]]) return NO;
//    return BigNumberCompare(self, other) == NSOrderedSame;
//}
//
//- (NSComparisonResult)compare:(BigNumber *)other {
//    return BigNumberCompare(self, other);
//}
//
//#pragma mark - Comparison
//
//
//- (BigNumber*) min:(BigNumber*)other {
//    return (BigNumberCompare(self, other) <= 0) ? self : other;
//}
//
//- (BigNumber*) max:(BigNumber*)other {
//    return (BigNumberCompare(self, other) >= 0) ? self : other;
//}
//
//- (BOOL) less:(BigNumber *)other           { return BigNumberCompare(self, other) <  0; }
//- (BOOL) lessOrEqual:(BigNumber *)other    { return BigNumberCompare(self, other) <= 0; }
//- (BOOL) greater:(BigNumber *)other        { return BigNumberCompare(self, other) >  0; }
//- (BOOL) greaterOrEqual:(BigNumber *)other { return BigNumberCompare(self, other) >= 0; }
//
//#pragma mark - Util
//- (void) withContext:(void(^)(BN_CTX* pctx))block
//{
//    BN_CTX* pctx = BN_CTX_new();
//    block(pctx);
//    BN_CTX_free(pctx);
//}
//
//#pragma mark - Operations
//
//
//- (instancetype) add:(BigNumber*)other { // +=
//    BN_add(&(self->_bignum), &(self->_bignum), &(other->_bignum));
//    return self;
//}
//
//- (instancetype) add:(BigNumber*)other mod:(BigNumber*)mod {
//    BN_CTX* pctx = BN_CTX_new();
//    BN_mod_add(&(self->_bignum), &(self->_bignum), &(other->_bignum), &(mod->_bignum), pctx);
//    BN_CTX_free(pctx);
//    return self;
//}
//
//- (instancetype) subtract:(BigNumber *)other { // -=
//    BN_sub(&(self->_bignum), &(self->_bignum), &(other->_bignum));
//    return self;
//}
//
//- (instancetype) subtract:(BigNumber*)other mod:(BigNumber*)mod {
//    BN_CTX* pctx = BN_CTX_new();
//    BN_mod_sub(&(self->_bignum), &(self->_bignum), &(other->_bignum), &(mod->_bignum), pctx);
//    BN_CTX_free(pctx);
//    return self;
//}
//
//- (instancetype) multiply:(BigNumber*)other { // *=
//    BN_CTX* pctx = BN_CTX_new();
//    BN_mul(&(self->_bignum), &(self->_bignum), &(other->_bignum), pctx);
//    BN_CTX_free(pctx);
//    return self;
//}
//
//- (instancetype) multiply:(BigNumber*)other mod:(BigNumber *)mod {
//    BN_CTX* pctx = BN_CTX_new();
//    BN_mod_mul(&(self->_bignum), &(self->_bignum), &(other->_bignum), &(mod->_bignum), pctx);
//    BN_CTX_free(pctx);
//    return self;
//}
//
//- (instancetype) divide:(BigNumber*)other { // /=
//    BN_CTX* pctx = BN_CTX_new();
//    BN_div(&(self->_bignum), NULL, &(self->_bignum), &(other->_bignum), pctx);
//    BN_CTX_free(pctx);
//    return self;
//}
//
//- (instancetype) mod:(BigNumber*)other { // %=
//    BN_CTX* pctx = BN_CTX_new();
//    BN_div(NULL, &(self->_bignum), &(self->_bignum), &(other->_bignum), pctx);
//    BN_CTX_free(pctx);
//    return self;
//}
//
//- (instancetype) lshift:(unsigned int)shift { // <<=
//    BN_lshift(&(self->_bignum), &(self->_bignum), shift);
//    return self;
//}
//
//- (instancetype) rshift:(unsigned int)shift { // >>=
//    // Note: BN_rshift segfaults on 64-bit if 2^shift is greater than the number
//    //   if built on ubuntu 9.04 or 9.10, probably depends on version of OpenSSL
//    BigNumber* a = [BigNumber one];
//    [a lshift:shift];
//    if (BN_cmp(&(a->_bignum), &(self->_bignum)) > 0) {
//        BN_zero(&(self->_bignum));
//        return self;
//    }
//    
//    BN_rshift(&(self->_bignum), &(self->_bignum), shift);
//    return self;
//}
//
//- (instancetype) inverseMod:(BigNumber*)mod { // (a^-1) mod n
//    BN_CTX* pctx = BN_CTX_new();
//    BN_mod_inverse(&(self->_bignum), &(self->_bignum), &(mod->_bignum), pctx);
//    BN_CTX_free(pctx);
//    return self;
//}
//
//- (instancetype) exp:(BigNumber*)power { // pow(self, p)
//    BN_CTX* pctx = BN_CTX_new();
//    BN_exp(&(self->_bignum), &(self->_bignum), &(power->_bignum), pctx);
//    BN_CTX_free(pctx);
//    return self;
//}
//
//- (instancetype) exp:(BigNumber*)power mod:(BigNumber *)mod { // pow(self,p) % m
//    BN_CTX* pctx = BN_CTX_new();
//    BN_mod_exp(&(self->_bignum), &(self->_bignum), &(power->_bignum), &(mod->_bignum), pctx);
//    BN_CTX_free(pctx);
//    return self;
//}
//
//
//@end

@implementation _Hash

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

@implementation _Key

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

    EC_POINT_free(pub);
    BN_free(prv);
    EC_KEY_free(key);
    BN_CTX_free(ctx);

    return result;
}

+ (NSData *)deriveKey:(NSData *)password salt:(NSData *)salt iterations:(NSInteger)iterations keyLength:(NSInteger)keyLength {
    NSMutableData *result = [NSMutableData dataWithLength:keyLength];
    PKCS5_PBKDF2_HMAC(password.bytes, (int)password.length, salt.bytes, (int)salt.length, (int)iterations, EVP_sha512(), (int)keyLength, result.mutableBytes);
    return result;
}

@end

@implementation _HDKey

- (instancetype)initWithPrivateKey:(NSData *)privateKey publicKey:(NSData *)publicKey chainCode:(NSData *)chainCode depth:(uint8_t)depth fingerprint:(uint32_t)fingerprint childIndex:(uint32_t)childIndex {
    self = [super init];
    if (self) {
        _privateKey = privateKey;
        _publicKey = publicKey;
        _chainCode = chainCode;
        _depth = depth;
        _fingerprint = fingerprint;
        _childIndex = childIndex;
    }
    return self;
}

- (_HDKey *)derivedAtIndex:(uint32_t)index hardened:(BOOL)hardened {
    BN_CTX *ctx = BN_CTX_new();

    NSMutableData *data = [NSMutableData data];
    if (hardened) {
        uint8_t padding = 0;
        [data appendBytes:&padding length:1];
        [data appendData:self.privateKey];
    } else {
        [data appendData:self.publicKey];
    }

    uint32_t childIndex = OSSwapHostToBigInt32(hardened ? (0x80000000 | index) : index);
    [data appendBytes:&childIndex length:sizeof(childIndex)];

    NSData *digest = [_Hash hmacsha512:data key:self.chainCode];
    NSData *derivedPrivateKey = [digest subdataWithRange:NSMakeRange(0, 32)];
    NSData *derivedChainCode = [digest subdataWithRange:NSMakeRange(32, 32)];

    BIGNUM *curveOrder = BN_new();
    BN_hex2bn(&curveOrder, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141");

    BIGNUM *factor = BN_new();
    BN_bin2bn(derivedPrivateKey.bytes, (int)derivedPrivateKey.length, factor);
    // Factor is too big, this derivation is invalid.
    if (BN_cmp(factor, curveOrder) >= 0) {
        return nil;
    }

    NSMutableData *result;
    if (self.privateKey) {
        BIGNUM *privateKey = BN_new();
        BN_bin2bn(self.privateKey.bytes, (int)self.privateKey.length, privateKey);

        BN_mod_add(privateKey, privateKey, factor, curveOrder, ctx);
        // Check for invalid derivation.
        if (BN_is_zero(privateKey)) {
            return nil;
        }

        int numBytes = BN_num_bytes(privateKey);
        result = [NSMutableData dataWithLength:numBytes];
        BN_bn2bin(privateKey, result.mutableBytes);

        BN_free(privateKey);
    } else {
        BIGNUM *publicKey = BN_new();
        BN_bin2bn(self.publicKey.bytes, (int)self.publicKey.length, publicKey);
        EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);

        EC_POINT *point = EC_POINT_new(group);
        EC_POINT_bn2point(group, publicKey, point, ctx);
        EC_POINT_mul(group, point, factor, point, BN_value_one(), ctx);
        // Check for invalid derivation.
        if (EC_POINT_is_at_infinity(group, point) == 1) {
            return nil;
        }

        BIGNUM *n = BN_new();
        result = [NSMutableData dataWithLength:33];

        EC_POINT_point2bn(group, point, POINT_CONVERSION_COMPRESSED, n, ctx);
        BN_bn2bin(n, result.mutableBytes);

        BN_free(n);
        BN_free(publicKey);
        EC_POINT_free(point);
        EC_GROUP_free(group);
    }

    BN_free(factor);
    BN_free(curveOrder);
    BN_CTX_free(ctx);

    uint32_t *fingerPrint = (uint32_t *)[_Hash sha256ripemd160:self.publicKey].bytes;
    return [[_HDKey alloc] initWithPrivateKey:result publicKey:result chainCode:derivedChainCode depth:self.depth + 1 fingerprint:*fingerPrint childIndex:childIndex];
}

@end

@implementation _BigNumber

+ (NSData *)Integer2BN:(uint32_t)integer {
    // integer to BN
    BIGNUM bn;
    BN_init(&bn);
    BN_set_word(&bn, integer);
    
    // BN to Data
    size_t size = BN_bn2mpi(&bn, NULL);
    if (size <= 4) {
        return [NSData data];
    }
    NSMutableData* data = [NSMutableData dataWithLength:size];
    BN_bn2mpi(&bn, data.mutableBytes);
    return data;
//    [data replaceBytesInRange:NSMakeRange(0, 4) withBytes:NULL length:0];
//    BTCDataReverse(data);
//    return data;
}
+ (uint32_t)BN2Integer:(NSData *)data {
    // Data to BN
    BIGNUM bn;
    BN_init(&bn);
    BN_bin2bn(data.bytes, (int)data.length, &bn);
    
    // BN to integer
    return (uint32_t)BN_get_word(&bn);
}

@end

void BTCReverseBytesLength(void* bytes, NSUInteger length) {
    // K&R
    if (length <= 1) return;
    unsigned char* buf = bytes;
    unsigned char byte;
    NSUInteger i, j;
    for (i = 0, j = length - 1; i < j; i++, j--) {
        byte = buf[i];
        buf[i] = buf[j];
        buf[j] = byte;
    }
}

// Reverses byte order in the internal buffer of mutable data object.
void BTCDataReverse(NSMutableData* self) {
    BTCReverseBytesLength(self.mutableBytes, self.length);
}
