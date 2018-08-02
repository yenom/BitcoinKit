//
//  Address.swift
//
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 BitcoinCashKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public protocol Address {
    var network: Network { get }
    var type: AddressType { get }
    var data: Data { get }
    var base58: String { get }
    var cashaddr: String { get }
    var publicKey: Data? { get }
}

public enum AddressError: Error {
    case invalid
    case invalidScheme
    case invalidVersionByte
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
            throw AddressError.invalidVersionByte
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
    public init(data: Data, type: AddressType, network: Network) {
        let addressData: Data = [type.versionByte] + data
        self.data = data
        self.type = type
        self.network = network
        self.publicKey = nil
        self.base58 = publicKeyHashToAddress(addressData)
        self.cashaddr = Bech32.encode(addressData, prefix: network.scheme)
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
            throw AddressError.invalidScheme
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
    public init(data: Data, type: AddressType, network: Network) {
        let addressData: Data = [type.versionByte] + data
        self.data = data
        self.type = type
        self.network = network
        self.publicKey = nil
        self.base58 = publicKeyHashToAddress(addressData)
        self.cashaddr = Bech32.encode(addressData, prefix: network.scheme)
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
