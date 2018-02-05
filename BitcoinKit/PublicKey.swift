//
//  PublicKey.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/01.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation
import crypto

public struct PublicKey {
    let raw: Data
    public let network: Network

    init(privateKey: PrivateKey, network: Network) {
        self.network = network
        self.raw = PublicKey.from(privateKey: privateKey.raw)
    }

    init(bytes raw: Data, network: Network) {
        self.raw = raw
        self.network = network
    }

    // Version = 1 byte of 0 (zero); on the test network, this is 1 byte of 111
    // Key hash = Version concatenated with RIPEMD-160(SHA-256(public key))
    // Checksum = 1st 4 bytes of SHA-256(SHA-256(Key hash))
    // Bitcoin Address = Base58Encode(Key hash concatenated with Checksum)
    public func toAddress() -> String {
        let hash = Data([network.pubkeyhash]) + Crypto.sha256ripemd160(raw)
        return publicKeyHashToAddress(hash)
    }

    static func from(privateKey raw: Data, compression: Bool = false) -> Data {
        let ctx = BN_CTX_new();
        defer { BN_CTX_free(ctx) }

        let eckey = EC_KEY_new_by_curve_name(NID_secp256k1);
        defer { EC_KEY_free(eckey) }
        let group = EC_KEY_get0_group(eckey);

        let privateKey = BN_new()
        defer { BN_free(privateKey) }
        _ = raw.withUnsafeBytes { BN_bin2bn($0, Int32(raw.count), privateKey) }

        let point = EC_POINT_new(group);
        defer { EC_POINT_free(point) }
        EC_POINT_mul(group, point, privateKey, nil, nil, ctx)
        EC_KEY_set_private_key(eckey, privateKey)
        EC_KEY_set_public_key(eckey, point)

        if compression {
            EC_KEY_set_conv_form(eckey, POINT_CONVERSION_COMPRESSED)
            var result: UnsafeMutablePointer<UInt8>? = nil
            let length = i2o_ECPublicKey(eckey, &result)
            let publicKey = result!.buffer(withLength: Int(length))
            var data = Data(publicKey)
            return data
        } else {
            var data = Data(count: 65)
            let publicKey = BN_new()
            defer { BN_free(publicKey) }

            EC_POINT_point2bn(group, point, POINT_CONVERSION_UNCOMPRESSED, publicKey, ctx)
            _ = data.withUnsafeMutableBytes { BN_bn2bin(publicKey, $0) }
            return data
        }
    }
}

extension PublicKey : Equatable {
    public static func ==(lhs: PublicKey, rhs: PublicKey) -> Bool {
        return lhs.network == rhs.network && lhs.raw == rhs.raw
    }
}

extension PublicKey : CustomStringConvertible {
    public var description: String {
        return raw.hex
    }
}

extension UnsafeMutablePointer {
    func buffer(withLength length: Int) -> [Pointee] {
        var buff = Array<Pointee!>(repeating: nil, count: length)
        for i in 0 ..< length {
            buff[i] = self[i]
        }
        return buff
    }
}
