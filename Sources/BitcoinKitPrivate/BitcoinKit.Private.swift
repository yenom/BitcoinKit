//
//  BitcoinKit.Private.swift
//  BitcoinKit
//
//  Created by Yusuke Ito on 03/24/18.
//  Copyright © 2018 Yusuke Ito. All rights reserved.
//

import Foundation
import COpenSSL
import secp256k1

public class _Hash {
    public static func sha1(_ data: Data) -> Data {
        var result = [UInt8](repeating: 0, count: Int(SHA_DIGEST_LENGTH))
        data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            SHA1(ptr, data.count, &result)
            return
        }
        return Data(result)
    }
    
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
    
    static func sha256ripemd160(_ data: Data) -> Data {
        return ripemd160(sha256(data))
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
    public static func deriveKey(_ password: Data, salt: Data, iterations:Int, keyLength: Int) -> Data {
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
    public let privateKey: Data?
    public let publicKey: Data?
    public let chainCode: Data
    public let depth: UInt8
    public let fingerprint: UInt32
    public let childIndex: UInt32
    
    public init(privateKey: Data?, publicKey: Data?, chainCode: Data, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }
    public func derived(at index: UInt32, hardened: Bool) -> _HDKey? {
        
        let ctx = BN_CTX_new()
        defer {
            BN_CTX_free(ctx)
        }
        var data = Data()
        if hardened {
            data.append(0) // padding
            data += privateKey ?? Data()
        } else {
            data += publicKey ?? Data()
        }
        
        var childIndex = UInt32(hardened ? (0x80000000 | index) : index).bigEndian
        data.append(UnsafeBufferPointer(start: &childIndex, count: 1))
        let digest = _Hash.hmacsha512(data, key: self.chainCode)
        let derivedPrivateKey = digest[0..<32]
        let derivedChainCode = digest[32..<(32+32)]
        var curveOrder = BN_new()
        defer {
            BN_free(curveOrder)
        }
        BN_hex2bn(&curveOrder, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")
        
        let factor = BN_new()
        defer {
            BN_free(factor)
        }
        derivedPrivateKey.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            BN_bin2bn(ptr, Int32(derivedPrivateKey.count), factor)
            return
        }
        // Factor is too big, this derivation is invalid.
        if BN_cmp(factor, curveOrder) >= 0 {
            return nil
        }
        
        if let privateKey = self.privateKey {
            let privateKeyNum = BN_new()!
            defer {
                BN_free(privateKeyNum)
            }
            privateKey.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
                BN_bin2bn(ptr, Int32(privateKey.count), privateKeyNum)
                return
            }
            BN_mod_add(privateKeyNum, privateKeyNum, factor, curveOrder, ctx)
            
            // Check for invalid derivation.
            //if BN_is_zero(privateKeyNum) {
            //    return nil
            //}
            if privateKeyNum.pointee.top == 0 { // BN_is_zero
                return nil
            }
            let numBytes = ((BN_num_bits(privateKeyNum)+7)/8) // BN_num_bytes
            var result = [UInt8](repeating: 0, count: Int(numBytes))
            BN_bn2bin(privateKeyNum, &result)
            let fingerprintData = _Hash.sha256ripemd160(publicKey ?? Data())
            let fingerprintArray = fingerprintData.withUnsafeBytes {
                [UInt32](UnsafeBufferPointer(start: $0, count: fingerprintData.count))
            }
            let reusltData = Data(result)
            return _HDKey(privateKey: reusltData,
                               publicKey: reusltData,
                               chainCode: derivedChainCode,
                               depth: depth + 1,
                               fingerprint: fingerprintArray[0],
                               childIndex: childIndex)
        } else if let publicKey = self.publicKey {
            let publicKeyNum = BN_new()
            defer {
                BN_free(publicKeyNum)
            }
            
            publicKey.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
                BN_bin2bn(ptr, Int32(publicKey.count), publicKeyNum)
                return
            }
            let group = EC_GROUP_new_by_curve_name(NID_secp256k1)
            let point = EC_POINT_new(group)
            defer {
                EC_POINT_free(point)
            }
            EC_POINT_bn2point(group, publicKeyNum, point, ctx)
            EC_POINT_mul(group, point, factor, point, BN_value_one(), ctx)
            
            // Check for invalid derivation.
            if EC_POINT_is_at_infinity(group, point) == 1 {
                return nil
            }
            let n = BN_new()
            defer {
                BN_free(n)
            }
            var result = [UInt8](repeating: 0, count: 33)
            EC_POINT_point2bn(group, point, POINT_CONVERSION_COMPRESSED, n, ctx)
            BN_bn2bin(n, &result)
            let fingerprintData = _Hash.sha256ripemd160(publicKey)
            let fingerprintArray = fingerprintData.withUnsafeBytes {
                [UInt32](UnsafeBufferPointer(start: $0, count: fingerprintData.count))
            }
            let reusltData = Data(result)
            return _HDKey(privateKey: reusltData,
                          publicKey: reusltData,
                          chainCode: derivedChainCode,
                          depth: depth + 1,
                          fingerprint: fingerprintArray[0],
                          childIndex: childIndex)
        } else {
            return nil
        }
    }
}

public class _Crypto {
    public static func signMessage(_ data: Data, withPrivateKey privateKey: Data) throws -> Data {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        defer { secp256k1_context_destroy(ctx) }
        
        let signature = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signature.deallocate() }
        let status = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) in
            privateKey.withUnsafeBytes { secp256k1_ecdsa_sign(ctx, signature, ptr, $0, nil, nil) }
        }
        guard status == 1 else { throw CryptoError.signFailed }
        
        let normalizedsig = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { normalizedsig.deallocate() }
        secp256k1_ecdsa_signature_normalize(ctx, normalizedsig, signature)
        
        var length: size_t = 128
        var der = Data(count: length)
        guard der.withUnsafeMutableBytes({ return secp256k1_ecdsa_signature_serialize_der(ctx, $0, &length, normalizedsig) }) == 1 else { throw CryptoError.noEnoughSpace }
        der.count = length
        
        return der
    }
    
    public static func verifySignature(_ signature: Data, message: Data, publicKey: Data) throws -> Bool {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY))!
        defer { secp256k1_context_destroy(ctx) }
        
        let signaturePointer = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signaturePointer.deallocate() }
        guard signature.withUnsafeBytes({ secp256k1_ecdsa_signature_parse_der(ctx, signaturePointer, $0, signature.count) }) == 1 else {
            throw CryptoError.signatureParseFailed
        }
        
        let pubkeyPointer = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        defer { pubkeyPointer.deallocate() }
        guard publicKey.withUnsafeBytes({ secp256k1_ec_pubkey_parse(ctx, pubkeyPointer, $0, publicKey.count) }) == 1 else {
            throw CryptoError.publicKeyParseFailed
        }
        
        guard message.withUnsafeBytes ({ secp256k1_ecdsa_verify(ctx, signaturePointer, $0, pubkeyPointer) }) == 1 else {
            return false
        }
        
        return true
    }
    
    public enum CryptoError: Error {
        case signFailed
        case noEnoughSpace
        case signatureParseFailed
        case publicKeyParseFailed
    }
}
