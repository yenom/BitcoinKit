//
//  BitcoinKit.Private.swift
//  BitcoinKit
//
//  Created by Yusuke Ito on 03/24/18.
//  Copyright © 2018 Yusuke Ito. All rights reserved.
//

import Foundation
import COpenSSL

public class _Hash {
    public static func sha256(_ data: Data) -> Data {
        var result = [UInt8](repeating: 0, count: Int(SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            SHA256(ptr, data.count, &result)
            return
        }
        return Data(result)
    }
    public static func ripemd160(_ data: Data) -> Data {
        var result = [UInt8](repeating: 0, count: Int(RIPEMD160_DIGEST_LENGTH))
        data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            RIPEMD160(ptr, data.count, &result)
            return
        }
        return Data(result)
    }
    public static func hmacsha512(_ data: Data, key: Data) -> Data {
        var result = [UInt8](repeating: 0, count: Int(SHA512_DIGEST_LENGTH))
        var length: UInt32 = UInt32(SHA512_DIGEST_LENGTH)
        data.withUnsafeBytes { (dataPtr: UnsafePointer<UInt8>) in
            key.withUnsafeBytes { (keyPtr: UnsafePointer<UInt8>) in
                HMAC(EVP_sha512(), keyPtr, Int32(key.count), dataPtr, data.count, &result, &length)
                return
            }
        }
        return Data(result)
    }
}

public class _Key {
    public static func computePublicKey(fromPrivateKey privateKey: Data, compression: Bool) -> Data {
        
        let ctx = BN_CTX_new()
        defer {
            BN_CTX_free(ctx)
        }
        let key = EC_KEY_new_by_curve_name(NID_secp256k1)
        defer {
            EC_KEY_free(key)
        }
        let group = EC_KEY_get0_group(key)
        
        
        let prv = BN_new()
        defer {
            BN_free(prv)
        }
        privateKey.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            BN_bin2bn(ptr, Int32(privateKey.count), prv)
            return
        }
        
        let pub = EC_POINT_new(group)
        defer {
            EC_POINT_free(pub)
        }
        EC_POINT_mul(group, pub, prv, nil, nil, ctx)
        EC_KEY_set_private_key(key, prv)
        EC_KEY_set_public_key(key, pub)
        
        if compression {
            EC_KEY_set_conv_form(key, POINT_CONVERSION_COMPRESSED)
            var ptr: UnsafeMutablePointer<UInt8>? = nil
            let length = i2o_ECPublicKey(key, &ptr)
            return Data(bytes: ptr!, count: Int(length))
        } else {
            var result = [UInt8](repeating: 0, count: 65)
            let n = BN_new()
            defer {
                BN_free(n)
            }
            EC_POINT_point2bn(group, pub, POINT_CONVERSION_UNCOMPRESSED, n, ctx)
            BN_bn2bin(n, &result)
            return Data(result)
        }
    }
    public static func deriveKey(_ password: Data, salt: Data, iterations:NSInteger, keyLength: NSInteger) -> Data {
        var result = [UInt8](repeating: 0, count: keyLength)
        password.withUnsafeBytes { (passwordPtr: UnsafePointer<Int8>) in
            salt.withUnsafeBytes { (saltPtr: UnsafePointer<UInt8>) in
                PKCS5_PBKDF2_HMAC(passwordPtr, Int32(password.count), saltPtr, Int32(salt.count), Int32(iterations), EVP_sha512(), Int32(keyLength), &result)
                return
            }
        }
        return Data(result)
    }
}

public class _HDKey {
    public let publicKey: Data?
    public let privateKey: Data?
    public let chainCode: Data
    public let depth: UInt8
    public let fingerprint: UInt32
    public let childIndex: UInt32
    
    public init(privateKey: Data?, publicKey: Data?, chainCode: Data, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        fatalError("unimplemented")
    }
    public func derived(at: UInt32, hardened: Bool) -> _HDKey? {
        fatalError("unimplemented")
    }
}
