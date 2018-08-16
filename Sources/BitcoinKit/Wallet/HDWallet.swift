//
//  HDWallet.swift
//
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 BitcoinKit developers
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

public final class HDWallet {
    public let network: Network

    public var transactions: [Transaction] {
        return []
    }

    public var unspentTransactions: [Transaction] {
        return []
    }

    public var balance: UInt64 {
        return 0
    }

    private let seed: Data
    private let keychain: HDKeychain

    private let purpose: UInt32
    private let coinType: UInt32
    var account: UInt32
    var externalIndex: UInt32
    var internalIndex: UInt32

    public init(seed: Data, network: Network) {
        self.seed = seed
        self.network = network
        keychain = HDKeychain(seed: seed, network: network)

        // m / purpose' / coin_type' / account' / change / address_index
        //
        // Purpose is a constant set to 44' (or 0x8000002C) following the BIP43 recommendation.
        // It indicates that the subtree of this node is used according to this specification.
        // Hardened derivation is used at this level.
        purpose = 44

        // One master node (seed) can be used for unlimited number of independent cryptocoins such as Bitcoin, Litecoin or Namecoin. However, sharing the same space for various cryptocoins has some disadvantages.
        // This level creates a separate subtree for every cryptocoin, avoiding reusing addresses across cryptocoins and improving privacy issues.
        // Coin type is a constant, set for each cryptocoin. Cryptocoin developers may ask for registering unused number for their project.
        // The list of already allocated coin types is in the chapter "Registered coin types" below.
        // Hardened derivation is used at this level.
        coinType = network == .mainnet ? 0 : 1

        // This level splits the key space into independent user identities, so the wallet never mixes the coins across different accounts.
        // Users can use these accounts to organize the funds in the same fashion as bank accounts; for donation purposes (where all addresses are considered public), for saving purposes, for common expenses etc.
        // Accounts are numbered from index 0 in sequentially increasing manner. This number is used as child index in BIP32 derivation.
        // Hardened derivation is used at this level.
        // Software should prevent a creation of an account if a previous account does not have a transaction history (meaning none of its addresses have been used before).
        // Software needs to discover all used accounts after importing the seed from an external source. Such an algorithm is described in "Account discovery" chapter.
        account = 0

        // Constant 0 is used for external chain and constant 1 for internal chain (also known as change addresses).
        // External chain is used for addresses that are meant to be visible outside of the wallet (e.g. for receiving payments).
        // Internal chain is used for addresses which are not meant to be visible outside of the wallet and is used for return transaction change.
        // Public derivation is used at this level.

        // Addresses are numbered from index 0 in sequentially increasing manner. This number is used as child index in BIP32 derivation.
        // Public derivation is used at this level.
        externalIndex = 0
        internalIndex = 0
    }

    // MARK: - External Addresses & Keys (Receive Addresses & Keys)
    public func receiveAddress() throws -> Address {
        return try receiveAddress(index: externalIndex)
    }

    public func receiveAddress(index: UInt32) throws -> Address {
        let key = try publicKey(index: index)
        return key.toCashaddr()
    }

    public func publicKey(index: UInt32) throws -> PublicKey {
        return try extendedPublicKey(index: index).publicKey()
    }

    public func privateKey(index: UInt32) throws -> PrivateKey {
        return try extendedPrivateKey(index: index).privateKey()
    }

    public func extendedPublicKey(index: UInt32) throws -> HDPublicKey {
        return try extendedPrivateKey(index: index).extendedPublicKey()
    }

    public func extendedPrivateKey(index: UInt32) throws -> HDPrivateKey {
        let privateKey = try keychain.derivedKey(path: "m/\(purpose)'/\(coinType)'/\(account)'/\(Chain.external.rawValue)/\(index)")
        return privateKey
    }

    // MARK: - Internal Addresses & Keys (Change Addresses& Keys)
    public func changeAddress() throws -> Address {
        return try changeAddress(index: internalIndex)
    }

    public func changeAddress(index: UInt32) throws -> Address {
        let key = try changePublicKey(index: index)
        return key.toCashaddr()
    }

    public func changePublicKey(index: UInt32) throws -> PublicKey {
        return try changeExtendedPublicKey(index: index).publicKey()
    }

    public func changePrivateKey(index: UInt32) throws -> PrivateKey {
        return try changeExtendedPrivateKey(index: index).privateKey()
    }

    public func changeExtendedPublicKey(index: UInt32) throws -> HDPublicKey {
        return try changeExtendedPrivateKey(index: index).extendedPublicKey()
    }

    public func changeExtendedPrivateKey(index: UInt32) throws -> HDPrivateKey {
        let privateKey = try keychain.derivedKey(path: "m/\(purpose)'/\(coinType)'/\(account)'/\(Chain.internal.rawValue)/\(index)")
        return privateKey
    }

    enum Chain: Int {
        case external
        case `internal`
    }
}
