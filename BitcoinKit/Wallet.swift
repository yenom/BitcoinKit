//
//  Wallet.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/31.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public protocol WalletProtocol {
    var network: Network { get }
    var address: String { get }
}

final public class Wallet {
    public let privateKey: PrivateKey
    public let publicKey: PublicKey

    public let network: Network

    public init(privateKey: PrivateKey) {
        self.privateKey = privateKey
        self.publicKey = privateKey.publicKey()
        self.network = privateKey.network
    }

    public init(wif: String) throws {
        self.privateKey = try PrivateKey(wif: wif)
        self.publicKey = privateKey.publicKey()
        self.network = privateKey.network
    }

    public func serialized() -> Data {
        var data = Data()
        data = privateKey.raw
        data = publicKey.raw
        return data
    }
}

extension Wallet : WalletProtocol {
    public var address: String {
        return publicKey.toAddress()
    }
}

extension Wallet : Encodable {
    enum CodingKeys: String, CodingKey {
        case privateKey
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(privateKey.toWIF(), forKey: .privateKey)
    }
}

extension Wallet : Decodable {
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let wif = try container.decode(String.self, forKey: .privateKey)
        try self.init(wif: wif)
    }
}

public final class HDWallet {
    public let privateKey: HDPrivateKey
    public let publicKey: HDPublicKey

    public let network: Network

    let seed: Data

    public init(seed: Data, network: Network) {
        self.seed = seed
        self.network = network
        privateKey = HDPrivateKey(seed: seed, network: network)
        publicKey = privateKey.publicKey()
    }
}

extension HDWallet : WalletProtocol {
    public var address: String {
        return publicKey.toAddress()
    }
}

extension HDWallet : Encodable {
    enum CodingKeys: String, CodingKey {
        case seed
        case network
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(seed, forKey: .seed)
        try container.encode(network.alias, forKey: .network)
    }
}

extension HDWallet : Decodable {
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let seed = try container.decode(Data.self, forKey: .seed)
        let network = try container.decode(String.self, forKey: .network)
        self.init(seed: seed, network: network == "mainnet" ? .mainnet : .testnet)
    }
}
