//
//  Wallet.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/31.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

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
