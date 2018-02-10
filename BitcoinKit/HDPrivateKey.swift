//
//  DeterministicKey.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/04.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation
import BitcoinKit.Private

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
        let hmac = Crypto.hmacsha512(data: seed, key: "Bitcoin seed".data(using: .ascii)!)
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
        let pubKey = publicKey().raw
        if let keys = BitcoinKitInternal.deriveKey(raw, publicKey: pubKey, chainCode: chainCode, at: index, hardened: hardened) {
            let fingerPrint: UInt32 = Crypto.sha256ripemd160(pubKey).withUnsafeBytes { $0.pointee }
            return HDPrivateKey(privateKey: keys[0],
                                chainCode: keys[1],
                                network: network,
                                depth: depth + 1,
                                fingerprint: fingerPrint,
                                childIndex: (hardened ? (0x80000000 | index) : index).bigEndian)
        }
        throw KeyChainError.derivateionFailed
    }
}

public enum KeyChainError : Error {
    case invalidChildIndex
    case derivateionFailed
}
