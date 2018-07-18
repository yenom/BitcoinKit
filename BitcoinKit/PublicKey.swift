//
//  PublicKey.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/01.
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

public struct PublicKey {
    let raw: Data
    public var pubkeyHash: Data {
        return Crypto.sha256ripemd160(raw)
    }
    public let network: Network
    public let isCompressed: Bool

    init(privateKey: PrivateKey) {
        self.network = privateKey.network
        self.isCompressed = privateKey.isPublicKeyCompressed
        self.raw = PublicKey.from(privateKey: privateKey.raw, compression: privateKey.isPublicKeyCompressed)
    }

    init(bytes raw: Data, network: Network) {
        self.raw = raw
        self.network = network
        let header = raw[0]
        self.isCompressed = (header == 0x02 || header == 0x03)
    }

    /// Version = 1 byte of 0 (zero); on the test network, this is 1 byte of 111
    /// Key hash = Version concatenated with RIPEMD-160(SHA-256(public key))
    /// Checksum = 1st 4 bytes of SHA-256(SHA-256(Key hash))
    /// Bitcoin Address = Base58Encode(Key hash concatenated with Checksum)
    public func toAddress() -> String {
        let versionByte: Data = Data([network.pubkeyhash])
        return publicKeyHashToAddress(versionByte + pubkeyHash)
    }

    public func toCashaddr() -> String {
        let versionByte: Data = Data([VersionByte.pubkeyHash160])
        return Bech32.encode(versionByte + pubkeyHash, prefix: network.scheme)
    }

    static func from(privateKey raw: Data, compression: Bool = false) -> Data {
        return _Key.computePublicKey(fromPrivateKey: raw, compression: compression)
    }
}

extension PublicKey: Equatable {
    // swiftlint:disable:next operator_whitespace
    public static func ==(lhs: PublicKey, rhs: PublicKey) -> Bool {
        return lhs.network == rhs.network && lhs.raw == rhs.raw
    }
}

extension PublicKey: CustomStringConvertible {
    public var description: String {
        return raw.hex
    }
}
