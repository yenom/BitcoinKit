//
//  DeterministicKey.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/04.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation
import crypto

public class HDPrivateKey {
    public let network: Network
    public let depth: UInt8
    public let fingerprint: UInt32
    public let childIndex: UInt32

    let raw: Data
    let chainCode: Data

    public init(privateKey: Data, chainCode: Data, network: Network = .testnet) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.network = network
        self.depth = 0
        self.fingerprint = 0
        self.childIndex = 0
    }

    public convenience init(seed: Data, network: Network = .testnet) {
        let hmac = Crypto.hmacsha512(key: "Bitcoin seed".data(using: .ascii)!, data: seed)
        let privateKey = hmac[0..<32]
        let chainCode = hmac[32..<64]
        self.init(privateKey: privateKey, chainCode: chainCode, network: network)
    }

    init(privateKey: Data, chainCode: Data, network: Network = .testnet, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.network = network
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }

    public func publicKey() -> HDPublicKey {
        return HDPublicKey(privateKey: self, chainCode: chainCode, network: network, depth: depth, fingerprint: fingerprint, childIndex: childIndex)
    }

    public func extended() -> String {
        var data = Data()
        data += network.xprivkey.bigEndian
        data += depth.littleEndian
        data += fingerprint.littleEndian
        data += childIndex.littleEndian
        data += chainCode
        data += UInt8(0)
        data += raw
        let checksum = Crypto.sha256sha256(data).prefix(4)
        return Base58.encode(data + checksum)
    }

    public func derived(at index: UInt32, hardened: Bool = false) throws -> HDPrivateKey {
        // As we use explicit parameter "hardened", do not allow higher bit set.
        if ((0x80000000 & index) != 0) {
            throw KeyChainError.invalidChildIndex
        }

        let ctx = BN_CTX_new()
        defer { BN_CTX_free(ctx) }

        var data = Data()
        if hardened {
            data += UInt8(0)
            data += raw
        } else {
            data += publicKey().raw
        }

        var index = UInt32(hardened ? (0x80000000 | index) : index).bigEndian
        data += index

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

        let pkNum = BN_new()
        defer { BN_free(pkNum) }
        _ = raw.withUnsafeBytes { BN_bin2bn($0, Int32(raw.count), pkNum) }

        BN_mod_add(pkNum, pkNum, factor, curveOrder, ctx)
        guard pkNum!.pointee.top > 0 else {
            throw KeyChainError.derivateionFailed
        }

        let numBytes = Int((BN_num_bits(pkNum) + 7) / 8)
        var derivedPrivateKey = Data(count: numBytes)
        _ = derivedPrivateKey.withUnsafeMutableBytes { BN_bn2bin(pkNum, $0) }

        let derivedFingerPrint: UInt32 = Crypto.sha256ripemd160(publicKey().raw).withUnsafeBytes { $0.pointee }
        return HDPrivateKey(privateKey: derivedPrivateKey,
                            chainCode: derivedChainCode,
                            network: network,
                            depth: depth + 1,
                            fingerprint: derivedFingerPrint,
                            childIndex: index)
    }
}

public enum KeyChainError : Error {
    case invalidChildIndex
    case derivateionFailed
}
