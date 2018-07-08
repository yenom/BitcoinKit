//
//  PublicKey.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/01.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation
import BitcoinKit.Private

public struct PublicKey {
    let raw: Data
    var pubkeyHash: Data {
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
