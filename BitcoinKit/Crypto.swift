//
//  Crypto.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/30.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation
import crypto
import secp256k1

public struct Crypto {
    public static func sha256(_ plain: Data) -> Data {
        let length = Int(SHA256_DIGEST_LENGTH)
        var result = [UInt8](repeating: 0, count: length)
        _ = plain.withUnsafeBytes { SHA256($0, plain.count, &result) }
        return Data(bytes: result, count: length)
    }
    
    public static func sha256sha256(_ plain: Data) -> Data {
        return sha256(sha256(plain))
    }

    public static func ripemd160(_ plain: Data) -> Data {
        let length = Int(RIPEMD160_DIGEST_LENGTH)
        var result = [UInt8](repeating: 0, count: length)
        _ = plain.withUnsafeBytes { RIPEMD160($0, plain.count, &result) }
        return Data(bytes: result, count: length)
    }

    public static func sha256ripemd160(_ plain: Data) -> Data {
        return ripemd160(sha256(plain))
    }

    public static func hmacsha512(key: Data, data: Data) -> Data {
        var length = UInt32(SHA512_DIGEST_LENGTH)
        var result = [UInt8](repeating: 0, count: Int(length))
        _ = key.withUnsafeBytes { (keyPtr) in
            data.withUnsafeBytes { (dataPtr) in
                HMAC(EVP_sha512(), keyPtr, Int32(key.count), dataPtr, data.count, &result, &length)
            }
        }
        return Data(result)
    }

    public static func sign(_ data: Data, privateKey: PrivateKey) throws -> Data {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        defer { secp256k1_context_destroy(ctx) }

        let signature = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signature.deallocate(capacity: 1) }
        let status = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            privateKey.raw.withUnsafeBytes { secp256k1_ecdsa_sign(ctx, signature, ptr, $0, nil, nil) }
        }
        guard status == 1 else { throw CryptoError.signFailed }

        let normalizedsig = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { normalizedsig.deallocate(capacity: 1) }
        secp256k1_ecdsa_signature_normalize(ctx, normalizedsig, signature)

        var length: size_t = 128
        var der = Data(count: length)
        guard der.withUnsafeMutableBytes({ return secp256k1_ecdsa_signature_serialize_der(ctx, $0, &length, normalizedsig) }) == 1 else { throw CryptoError.noEnoughSpace }
        der.count = length

        return der
    }
}

public enum CryptoError : Error {
    case signFailed
    case noEnoughSpace
}
