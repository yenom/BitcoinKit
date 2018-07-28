//
//  DeterministicKey.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/04.
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 Shun Usami
//  Copyright © 2018 BitcoinCashKit developers
//  Licensed under the Apache License, Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  This file has been modified by the BitcoinCashKit developers for the BitcoinCashKit project.
//  The original file was from the bitcoinj project (https://github.com/kishikawakatsumi/BitcoinKit).
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

    public init(privateKey: Data, chainCode: Data, network: Network) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.network = network
        self.depth = 0
        self.fingerprint = 0
        self.childIndex = 0
    }

    public convenience init(seed: Data, network: Network) {
        let hmac = Crypto.hmacsha512(data: seed, key: "Bitcoin seed".data(using: .ascii)!)
        let privateKey = hmac[0..<32]
        let chainCode = hmac[32..<64]
        self.init(privateKey: privateKey, chainCode: chainCode, network: network)
    }

    init(privateKey: Data, chainCode: Data, network: Network, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.network = network
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }

    public func privateKey() -> PrivateKey {
        return PrivateKey(data: raw, network: network, isPublicKeyCompressed: true)
    }

    public func extendedPublicKey() -> HDPublicKey {
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
        if (0x80000000 & index) != 0 {
            fatalError("invalid child index")
        }

        guard let derivedKey = _HDKey(privateKey: raw, publicKey: extendedPublicKey().raw, chainCode: chainCode, depth: depth, fingerprint: fingerprint, childIndex: childIndex).derived(at: index, hardened: hardened) else {
            throw DerivationError.derivateionFailed
        }
        return HDPrivateKey(privateKey: derivedKey.privateKey!, chainCode: derivedKey.chainCode, network: network, depth: derivedKey.depth, fingerprint: derivedKey.fingerprint, childIndex: derivedKey.childIndex)
    }
}

public enum DerivationError: Error {
    case derivateionFailed
}
