//
//  HDPublicKey.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/04.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation
import crypto

public class HDPublicKey {
    public let network: Network
    public let depth: UInt8
    public let fingerprint: UInt32
    public let childIndex: UInt32

    let raw: Data
    let chainCode: Data

    init(privateKey: HDPrivateKey, network: Network) {
        self.network = network
        self.raw = PublicKey.from(privateKey: privateKey.raw, compression: true)
        self.chainCode = privateKey.chainCode
        self.depth = 0
        self.fingerprint = 0
        self.childIndex = 0
    }

    init(privateKey: HDPrivateKey, chainCode: Data, network: Network = .testnet, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.network = network
        self.raw = PublicKey.from(privateKey: privateKey.raw, compression: true)
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }

    init(raw: Data, chainCode: Data, network: Network = .testnet, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.network = network
        self.raw = raw
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }

    public func extended() -> String {
        var data = Data()
        data += network.xpubkey.bigEndian
        data += depth.littleEndian
        data += fingerprint.littleEndian
        data += childIndex.littleEndian
        data += chainCode
        data += raw
        let checksum = Crypto.sha256sha256(data).prefix(4)
        return Base58.encode(data + checksum)
    }
    
    public func toAddress() -> String {
        let hash = Data([network.pubkeyhash]) + Crypto.sha256ripemd160(raw)
        return publicKeyHashToAddress(hash)
    }

    public func derived(at index: UInt32) throws -> HDPublicKey {
        // As we use explicit parameter "hardened", do not allow higher bit set.
        if ((0x80000000 & index) != 0) {
            throw KeyChainError.invalidChildIndex
        }

        let ctx = BN_CTX_new()
        defer { BN_CTX_free(ctx) }

        var data = Data()
        data += raw
        data += index.bigEndian

        let digest = Crypto.hmacsha512(key: chainCode, data: data)

        let curveOrder = BN_new()
        defer { BN_free(curveOrder) }
        let curveData = Data(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
        _ = curveData.withUnsafeBytes { BN_bin2bn($0, Int32(curveData.count), curveOrder) }

        let factor = BN_new()
        defer { BN_free(factor) }
        let pk = digest[0..<32]
        _ = pk.withUnsafeBytes { BN_bin2bn($0, Int32(pk.count), factor) }
        guard BN_cmp(factor, curveOrder) < 0 else {
            throw KeyChainError.derivateionFailed
        }

        let derivedChainCode = digest[32..<64]

        let pubNum = BN_new()
        defer { BN_free(pubNum) }
        _ = raw.withUnsafeBytes { BN_bin2bn($0, Int32(raw.count), pubNum) }

        let group = EC_GROUP_new_by_curve_name(NID_secp256k1)
        defer { EC_GROUP_free(group) }

        let point = EC_POINT_new(group)
        defer { EC_POINT_free(point) }

        EC_POINT_bn2point(group, pubNum, point, ctx)
        EC_POINT_mul(group, point, factor, point, BN_value_one(), ctx)

        guard EC_POINT_is_at_infinity(group, point) != 1 else {
            throw KeyChainError.derivateionFailed
        }

        var derivedPublicKey = Data(count: 33)
        let pointNum = BN_new()
        defer { BN_free(pointNum) }
        EC_POINT_point2bn(group, point, POINT_CONVERSION_COMPRESSED, pointNum, ctx)
        _ = derivedPublicKey.withUnsafeMutableBytes { BN_bn2bin(pointNum, $0) }

        let derivedFingerPrint: UInt32 = Crypto.sha256ripemd160(raw).withUnsafeBytes { $0.pointee }

        return HDPublicKey(raw: derivedPublicKey,
                           chainCode: derivedChainCode,
                           network: network,
                           depth: depth + 1,
                           fingerprint: derivedFingerPrint,
                           childIndex: index)
    }
}
