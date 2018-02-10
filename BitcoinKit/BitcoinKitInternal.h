//
//  OpenSSL.h
//  BitcoinKit
//
//  Created by kishikawakatsumi on 2018/02/09.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface BitcoinKitInternal : NSObject

+ (NSData *)sha256:(NSData *)data;
+ (NSData *)ripemd160:(NSData *)data;
+ (NSData *)hmacsha512:(NSData *)data key:(NSData *)key;

+ (NSData *)computePublicKeyFromPrivateKey:(NSData *)privateKey compression:(BOOL)compression;

+ (NSData *)deriveKey:(NSData *)password salt:(NSData *)salt iterations:(NSInteger)iterations keyLength:(NSInteger)keyLength;
+ (nullable NSArray<NSData *> *)deriveKey:(nullable NSData *)privateKey publicKey:(NSData *)publicKey chainCode:(NSData *)chainCode atIndex:(uint32_t)index hardened:(BOOL)hardened;

@end
NS_ASSUME_NONNULL_END
