//
//  Address.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/31.
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

// TODO: このクラスはPubkeyHash Addressにしか対応していない。ScriptHashとかPrivateとか対応しないなら名前がおかしい。
public protocol Address {
    var network: Network { get }
    var type: AddressType { get }
    var data: Data { get }
    var base58: String { get }
    var cashaddr: String { get }
    var publicKey: Data? { get }
}

public struct LegacyAddress: Address {
    public let network: Network
    public let type: AddressType
    public let data: Data
    public let base58: Base58Check
    public let cashaddr: String
    public let publicKey: Data?

    public typealias Base58Check = String

    public init(_ publicKey: PublicKey) {
        self.network = publicKey.network
        self.type = .pubkeyHash
        self.publicKey = publicKey.raw
        self.data = Crypto.sha256ripemd160(publicKey.raw)
        self.base58 = publicKey.toAddress()
        self.cashaddr = publicKey.toCashaddr()
    }

    public init(_ publicKey: HDPublicKey) {
        self.network = publicKey.network
        self.type = .pubkeyHash
        self.publicKey = publicKey.raw
        self.data = Crypto.sha256ripemd160(publicKey.raw)
        self.base58 = publicKey.toAddress()
        self.cashaddr = publicKey.toCashaddr()
    }

    public init(_ base58: Base58Check) throws {
        guard let raw = Base58.decode(base58) else {
            throw AddressError.invalid
        }
        let checksum = raw.suffix(4)
        let pubKeyHash = raw.dropLast(4)
        let checksumConfirm = Crypto.sha256sha256(pubKeyHash).prefix(4)
        guard checksum == checksumConfirm else {
            throw AddressError.invalid
        }

        let network: Network
        let type: AddressType
        let addressPrefix = pubKeyHash[0]
        switch addressPrefix {
        case Network.mainnet.pubkeyhash:
            network = .mainnet
            type = .pubkeyHash
        case Network.testnet.pubkeyhash:
            network = .testnet
            type = .pubkeyHash
        case Network.mainnet.scripthash:
            network = .mainnet
            type = .scriptHash
        case Network.testnet.scripthash:
            network = .testnet
            type = .scriptHash
        default:
            // TODO: privatekey, xpriv, xpub
            throw AddressError.wrongNetwork
        }

        self.network = network
        self.type = type
        self.publicKey = nil
        self.data = pubKeyHash.dropFirst()
        self.base58 = base58

        // cashaddr
        switch type {
        case .pubkeyHash, .scriptHash:
            let payload = Data([type.versionByte160]) + self.data
            self.cashaddr = Bech32.encode(payload, prefix: network.scheme)
        default:
            self.cashaddr = ""
        }
    }
}

extension LegacyAddress: Equatable {
    // swiftlint:disable:next operator_whitespace
    public static func ==(lhs: LegacyAddress, rhs: LegacyAddress) -> Bool {
        return lhs.network == rhs.network && lhs.data == rhs.data && lhs.type == rhs.type
    }
}

extension LegacyAddress: CustomStringConvertible {
    public var description: String {
        return base58
    }
}

public struct Cashaddr: Address {
    public let network: Network
    public let type: AddressType
    public let data: Data
    public let base58: String
    public let cashaddr: CashaddrWithScheme
    public let publicKey: Data?

    public typealias CashaddrWithScheme = String

    public init(_ publicKey: PublicKey) {
        self.network = publicKey.network
        self.type = .pubkeyHash
        self.publicKey = publicKey.raw
        self.data = Crypto.sha256ripemd160(publicKey.raw)
        self.base58 = publicKey.toAddress()
        self.cashaddr = publicKey.toCashaddr()
    }

    public init(_ publicKey: HDPublicKey) {
        self.network = publicKey.network
        self.type = .pubkeyHash
        self.publicKey = publicKey.raw
        self.data = Crypto.sha256ripemd160(publicKey.raw)
        self.base58 = publicKey.toAddress()
        self.cashaddr = publicKey.toCashaddr()
    }

    public init(_ cashaddr: CashaddrWithScheme) throws {
        guard let decoded = Bech32.decode(cashaddr) else {
            throw AddressError.invalid
        }
        let (prefix, raw) = (decoded.prefix, decoded.data)
        self.cashaddr = cashaddr
        self.publicKey = nil

        switch prefix {
        case Network.mainnet.scheme:
            network = .mainnet
        case Network.testnet.scheme:
            network = .testnet
        default:
            throw AddressError.wrongNetwork
        }

        let versionByte = raw[0]
        let hash = raw.dropFirst()

        guard hash.count == VersionByte.getSize(from: versionByte) else {
            throw AddressError.invalidVersionByte
        }
        self.data = hash
        guard let typeBits = VersionByte.TypeBits(rawValue: (versionByte & 0b01111000)) else {
            throw AddressError.invalidVersionByte
        }

        switch typeBits {
        case .pubkeyHash:
            type = .pubkeyHash
            base58 = publicKeyHashToAddress(Data([network.pubkeyhash]) + data)
        case .scriptHash:
            type = .scriptHash
            base58 = publicKeyHashToAddress(Data([network.scripthash]) + data)
        }
    }
}

extension Cashaddr: Equatable {
    // swiftlint:disable:next operator_whitespace
    public static func ==(lhs: Cashaddr, rhs: Cashaddr) -> Bool {
        return lhs.network == rhs.network && lhs.data == rhs.data && lhs.type == rhs.type
    }
}

extension Cashaddr: CustomStringConvertible {
    public var description: String {
        return cashaddr
    }
}

public enum AddressError: Error {
    case invalid
    case wrongNetwork
    case invalidVersionByte
}
