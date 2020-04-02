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
        data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            SHA1(ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                 data.count,
                 &result)
            return
        }
        return Data(result)
    }
    
    public static func sha256(_ data: Data) -> Data {
        var result = [UInt8](repeating: 0, count: Int(SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            SHA256(ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                   data.count,
                   &result)
            return
        }
        return Data(result)
    }
    public static func ripemd160(_ data: Data) -> Data {
        var result = [UInt8](repeating: 0, count: Int(RIPEMD160_DIGEST_LENGTH))
        data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            RIPEMD160(ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                      data.count,
                      &result)
            return
        }
        return Data(result)
    }
    
    static func sha256ripemd160(_ data: Data) -> Data {
        return ripemd160(sha256(data))
    }
    
    public static func hmacsha512(_ data: Data, key: Data) -> Data {
        var length = UInt32(SHA512_DIGEST_LENGTH)
        var result = Data(count: Int(length))
        
        data.withUnsafeBytes { (dataPtr: UnsafeRawBufferPointer) in
            key.withUnsafeBytes { (keyPtr: UnsafeRawBufferPointer) in
                result.withUnsafeMutableBytes { (resultPtr: UnsafeMutableRawBufferPointer) in
                    HMAC(EVP_sha512(),
                         keyPtr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                         Int32(key.count),
                         dataPtr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                         data.count,
                         resultPtr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                         &length)
                    return
                }
            }
        }
        return result
    }
}

public class _SwiftKey {
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
        privateKey.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            BN_bin2bn(
                ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                Int32(privateKey.count),
                prv
            )
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
}

public class _Key {
    public static func deriveKey(_ password: Data, salt: Data, iterations:Int, keyLength: Int) -> Data {
        var result = [UInt8](repeating: 0, count: keyLength)
        password.withUnsafeBytes { (passwordPtr: UnsafeRawBufferPointer) in
            salt.withUnsafeBytes { (saltPtr: UnsafeRawBufferPointer) in
                PKCS5_PBKDF2_HMAC(
                    passwordPtr.bindMemory(to: Int8.self).baseAddress.unsafelyUnwrapped,
                    Int32(password.count),
                    saltPtr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                    Int32(salt.count),
                    Int32(iterations),
                    EVP_sha512(),
                    Int32(keyLength),
                    &result)
                return
            }
        }
        return Data(result)
    }
}

public class _HDKey {
    public let privateKey: Data?
    public let publicKey: Data
    public let chainCode: Data
    public let depth: UInt8
    public let fingerprint: UInt32
    public let childIndex: UInt32
    
    public init(privateKey: Data?, publicKey: Data, chainCode: Data, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }
    public func derived(at index: UInt32, hardened: Bool) -> _HDKey? {
        // index should be 0 through 2^31-1
        guard index < 0x80000000 else {
            return nil
        }
        let ctx = BN_CTX_new()
        defer {
            BN_CTX_free(ctx)
        }
        var data = Data()
        if hardened {
            guard let privateKey = privateKey else {
                return nil
            }
            data.append(0) // pads the private key to make it 33 bytes long
            data += privateKey
        } else {
            data += publicKey
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

        derivedPrivateKey.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            BN_bin2bn(
                ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                Int32(derivedPrivateKey.count),
                factor
            )
            return
        }
        // Factor is too big, this derivation is invalid.
        if BN_cmp(factor, curveOrder) >= 0 {
            return nil
        }
        
        var result: Data
        if let privateKey = self.privateKey {
            let privateKeyNum = BN_new()!
            defer {
                BN_free(privateKeyNum)
            }
            privateKey.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                BN_bin2bn(
                    ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                    Int32(privateKey.count),
                    privateKeyNum
                )
                return
            }
            BN_mod_add(privateKeyNum, privateKeyNum, factor, curveOrder, ctx)
            
            // Check for invalid derivation.
            if BN_is_zero(privateKeyNum) != 0 {
                return nil
            }
            let numBytes = ((BN_num_bits(privateKeyNum)+7)/8) // BN_num_bytes
            result = Data(count: Int(numBytes))
            result.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
                BN_bn2bin(
                    privateKeyNum,
                    ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped
                )
                return
            }
            if result.count < 32 {
                result = Data(repeating: 0, count: 32 - result.count) + result // 0 padding
            }
        } else {
            let publicKeyNum = BN_new()
            defer {
                BN_free(publicKeyNum)
            }
            
            publicKey.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                BN_bin2bn(
                    ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                    Int32(publicKey.count),
                    publicKeyNum
                )
                return
            }
            let group = EC_GROUP_new_by_curve_name(NID_secp256k1)
            let point = EC_POINT_new(group)
            defer {
                EC_POINT_free(point)
                EC_GROUP_free(group)
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
            EC_POINT_point2bn(group, point, POINT_CONVERSION_COMPRESSED, n, ctx)
            result = Data(count: 33)
            result.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
                BN_bn2bin(
                    n,
                    ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped
                )
                return
            }
        }
        
        let fingerprintData = _Hash.sha256ripemd160(publicKey)
        let fingerprint = fingerprintData.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
            ptr.load(as: UInt32.self)
        }
        return _HDKey(privateKey: result,
                      publicKey: result,
                      chainCode: derivedChainCode,
                      depth: depth + 1,
                      fingerprint: fingerprint,
                      childIndex: childIndex)

    }
}

public class _Crypto {
    public static func signMessage(_ data: Data, withPrivateKey privateKey: Data) throws -> Data {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        defer { secp256k1_context_destroy(ctx) }
        
        let signature = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signature.deallocate() }
        let status = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            privateKey.withUnsafeBytes {
                secp256k1_ecdsa_sign(
                    ctx,
                    signature,
                    ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                    $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                    nil,
                    nil
                )
            }
        }
        guard status == 1 else { throw CryptoError.signFailed }
        
        let normalizedsig = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { normalizedsig.deallocate() }
        secp256k1_ecdsa_signature_normalize(ctx, normalizedsig, signature)
        
        var length: size_t = 128
        var der = Data(count: length)
        guard der.withUnsafeMutableBytes({
            return secp256k1_ecdsa_signature_serialize_der(
                ctx,
                $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                &length,
                normalizedsig
            ) }) == 1 else { throw CryptoError.noEnoughSpace }
        der.count = length
        
        return der
    }
    
    public static func verifySignature(_ signature: Data, message: Data, publicKey: Data) throws -> Bool {
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY))!
        defer { secp256k1_context_destroy(ctx) }
        
        let signaturePointer = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
        defer { signaturePointer.deallocate() }
        guard signature.withUnsafeBytes({
            secp256k1_ecdsa_signature_parse_der(
                ctx,
                signaturePointer,
                $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                signature.count
            )
        }) == 1 else {
            throw CryptoError.signatureParseFailed
        }
        
        let pubkeyPointer = UnsafeMutablePointer<secp256k1_pubkey>.allocate(capacity: 1)
        defer { pubkeyPointer.deallocate() }
        guard publicKey.withUnsafeBytes({
            secp256k1_ec_pubkey_parse(
                ctx,
                pubkeyPointer,
                $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                publicKey.count
            ) }) == 1 else {
            throw CryptoError.publicKeyParseFailed
        }
        
        guard message.withUnsafeBytes ({
            secp256k1_ecdsa_verify(
                ctx,
                signaturePointer,
                $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                pubkeyPointer) }) == 1 else {
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

public class _EllipticCurve {
    public static func multiplyECPointX(_ ecPointX: Data, andECPointY ecPointY: Data, withScalar scalar: Data) -> Data {
        let ctx = BN_CTX_new()
        defer { BN_CTX_free(ctx) }
        let group = EC_GROUP_new_by_curve_name(NID_secp256k1)
        defer { EC_GROUP_free(group) }
        
        let multiplication_factor = BN_new()
        defer { BN_free(multiplication_factor) }
        scalar.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            BN_bin2bn(
                ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                Int32(scalar.count),
                multiplication_factor
            )
            return
        }
        
        let point_x = BN_new()
        defer { BN_free(point_x) }
        ecPointX.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            BN_bin2bn(
                ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                Int32(ecPointX.count),
                point_x
            )
            return
        }

        let point_y = BN_new();
        defer { BN_free(point_y) }
        ecPointY.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            BN_bin2bn(
                ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                Int32(ecPointY.count),
                point_y
            )
            return
        }

        let point = EC_POINT_new(group);
        defer { EC_POINT_free(point) }
        EC_POINT_set_affine_coordinates_GFp(group, point, point_x, point_y, ctx)

        let point_result_of_ec_multiplication = EC_POINT_new(group)
        defer { EC_POINT_free(point_result_of_ec_multiplication) }
        EC_POINT_mul(group, point_result_of_ec_multiplication, nil, point, multiplication_factor, ctx)
        
        var newPointXAndYPrefixedWithByte = [UInt8](repeating: 0, count: 65)
        let new_point_x_and_y_as_single_bn = BN_new()
        defer { BN_free(new_point_x_and_y_as_single_bn) }
        
        EC_POINT_point2bn(group, point_result_of_ec_multiplication, POINT_CONVERSION_UNCOMPRESSED, new_point_x_and_y_as_single_bn, ctx)

        BN_bn2bin(new_point_x_and_y_as_single_bn, &newPointXAndYPrefixedWithByte)
        
        return Data(newPointXAndYPrefixedWithByte)
    }

    public static func decodePointOnCurve(forCompressedPublicKey publicKeyCompressed: Data) -> Data {
        let ctx = BN_CTX_new()
        defer { BN_CTX_free(ctx) }
        
        let group = EC_GROUP_new_by_curve_name(NID_secp256k1)
        defer { EC_GROUP_free(group) }
        
        EC_GROUP_set_point_conversion_form(group, POINT_CONVERSION_COMPRESSED)
        let point = EC_POINT_new(group)
        defer { EC_POINT_free(point) }
        
        publicKeyCompressed.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            EC_POINT_oct2point(
                group,
                point,
                ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                Int(publicKeyCompressed.count),
                ctx
            )
            return
        }
        
        var newPointXAndYPrefixedWithByte = [UInt8](repeating: 0, count: 65)
        let new_point_x_and_y_as_single_bn = BN_new()
        defer { BN_free(new_point_x_and_y_as_single_bn) }
        
        EC_POINT_point2bn(group, point, POINT_CONVERSION_UNCOMPRESSED, new_point_x_and_y_as_single_bn, ctx)
        BN_bn2bin(new_point_x_and_y_as_single_bn, &newPointXAndYPrefixedWithByte)
        
        return Data(newPointXAndYPrefixedWithByte)
    }
}
