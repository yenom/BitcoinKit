//
//  HDPublicKey.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/04.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation
import BitcoinKit.Private

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
        if let keys = BitcoinKitInternal.deriveKey(nil, publicKey: raw, chainCode: chainCode, at: index, hardened: false) {
            let fingerPrint: UInt32 = Crypto.sha256ripemd160(raw).withUnsafeBytes { $0.pointee }
            return HDPublicKey(raw: keys[0],
                               chainCode: keys[1],
                               network: network,
                               depth: depth + 1,
                               fingerprint: fingerPrint,
                               childIndex: index)
        }
        throw KeyChainError.derivateionFailed
    }
}
