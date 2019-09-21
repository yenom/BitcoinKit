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

open class HDWallet {
    public enum Chain: Int {
        case external
        case `internal`
    }

    /// [Secret] Be very careful. This is a group of easy to remember words to generate seed data
    public let mnemonic: [String]?
    /// [Secret] Be very careful. This is the data to generate deterministic wallets
    public let seed: Data
    /// Network for the coni i.e. mainnet/testnet
    public let network: Network
    /// HDKeychain to derive keys
    private let keychain: HDKeychain
    /// [Secret] Be very careful. This is a root HDPrivateKey
    public var rootXPrivKey: HDPrivateKey
    /// [Secret] Be very careful. This is a root HDPublicKey
    public var rootXPubKey: HDPublicKey

    /// Purpose is a constant set to 44' (or 0x8000002C) following the BIP43 recommendation.
    open var purpose: UInt32 { return 44 }
    /// BIP44 CoinType which splits the key space into independent cryptocoins such as Bitcoin and BitcoinCash.
    open var coinType: UInt32 { return network.coinType.index }
    /// BIP44 Account which splits the key space into independent user identities, so the wallet never mixes the coins across different accounts.
    public var account: UInt32

    // Index for keys (Increment only.)
    /// Child index for BIP32 derivation to generate addresses that are meant to be visible outside of the wallet (e.g. for receiving payments).
    public private(set) var externalIndex: UInt32
    ///  Child index for BIP32 derivation to generate addresses which are not meant to be visible outside of the wallet and is used for return transaction change.
    public private(set) var internalIndex: UInt32

    /// [Cached] Latest Address for receiving payment.
    public var address: BitcoinAddress { return externalAddresses.last! }
    /// [Cached] Latest Address for change output.
    public var changeAddress: BitcoinAddress { return internalAddresses.last! }

    // MARK: - Private Keys
    /// [Secret] [Cached] Private keys for external addresses (receive).
    public private(set) var externalPrivKeys: [PrivateKey]!
    /// [Secret] [Cached] Private keys for internal addresses (change).
    public private(set) var internalPrivKeys: [PrivateKey]!
    /// [Secret] [Cached] Private keys combined both external and internal.
    public var privKeys: [PrivateKey] { return externalPrivKeys + internalPrivKeys }

    // MARK: - Public Keys
    /// [Cached] Public keys for external addresses (receive).
    public private(set) var externalPubKeys: [PublicKey]!
    /// [Cached] Public keys for internal addresses (change).
    public private(set) var internalPubKeys: [PublicKey]!
    /// [Cached] Public keys combined both external and internal.
    public var pubKeys: [PublicKey] { return externalPubKeys + internalPubKeys }

    // MARK: - Addresses
    /// [Cached] External addresses for receiving payment.
    public private(set) var externalAddresses: [BitcoinAddress]!
    /// [Cached] Internal addresses for change output.
    public private(set) var internalAddresses: [BitcoinAddress]!
    /// [Cached] Addresses combined both external and internal.
    public var addresses: [BitcoinAddress] { return externalAddresses + internalAddresses }

    private func initializeCache() {
        // Privkey cache
        self.externalPrivKeys = (0...externalIndex).map { privKey(index: $0, chain: .external) }
        self.internalPrivKeys = (0...internalIndex).map { privKey(index: $0, chain: .internal) }

        // Pubkey cache
        self.externalPubKeys = externalPrivKeys.map { $0.publicKey() }
        self.internalPubKeys = internalPrivKeys.map { $0.publicKey() }

        // Address cache
        self.externalAddresses = externalPubKeys.map { $0.toBitcoinAddress() }
        self.internalAddresses = internalPubKeys.map { $0.toBitcoinAddress() }
    }

    public init(seed: Data,
                externalIndex: UInt32,
                internalIndex: UInt32,
                network: Network,
                account: UInt32 = 0) {
        self.mnemonic = nil
        self.seed = seed
        self.network = network
        self.account = account
        self.externalIndex = externalIndex
        self.internalIndex = internalIndex
        self.keychain = HDKeychain(seed: seed, network: network)
        self.rootXPrivKey = HDPrivateKey(seed: seed, network: network)
        self.rootXPubKey = rootXPrivKey.extendedPublicKey()

        self.initializeCache()
    }

    public init(mnemonic: [String],
                passphrase: String,
                externalIndex: UInt32,
                internalIndex: UInt32,
                network: Network,
                account: UInt32 = 0) throws {
        let seed: Data = try Mnemonic.seed(mnemonic: mnemonic, passphrase: passphrase)
        self.mnemonic = mnemonic
        self.seed = seed
        self.network = network
        self.account = account
        self.externalIndex = externalIndex
        self.internalIndex = internalIndex
        self.keychain = HDKeychain(seed: seed, network: network)
        self.rootXPrivKey = HDPrivateKey(seed: seed, network: network)
        self.rootXPubKey = rootXPrivKey.extendedPublicKey()

        self.initializeCache()
    }

    /// Create HDWallet by generating random mnemonic. Passphrase is used as salt to generate seed from the mnemonic.
    public static func create(passphrase: String, network: Network) -> HDWallet {
        // swiftlint:disable:next force_try
        let mnemonic: [String] = try! Mnemonic.generate(strength: .default, language: .english)
        return try! HDWallet(mnemonic: mnemonic, passphrase: passphrase, externalIndex: 0, internalIndex: 0, network: network)
    }

    // MARK: keys and addresses
    /// m / purpose' / coin_type' / account' / change / address_index
    private func derivationPath(for index: UInt32, chain: Chain) -> String {
        return "m/\(purpose)'/\(coinType)'/\(account)'/\(chain.rawValue)/\(index)"
    }

    /// [Secret] [Non-Cache] Get xprivkey for index
    public func xprivKey(index: UInt32, chain: Chain) -> HDPrivateKey {
        // swiftlint:disable:next force_try
        return try! keychain.derivedKey(path: derivationPath(for: index, chain: chain))
    }

    /// [Non-Cache] Get xpubkey for index
    public func xpubKey(index: UInt32, chain: Chain) -> HDPublicKey {
        return xprivKey(index: index, chain: chain).extendedPublicKey()
    }

    /// [Secret] [Non-Cache] Get privkey for index
    public func privKey(index: UInt32, chain: Chain) -> PrivateKey {
        return xprivKey(index: index, chain: chain).privateKey()
    }

    /// [Non-Cache] Get pubkey for index
    public func pubKey(index: UInt32, chain: Chain) -> PublicKey {
        return xpubKey(index: index, chain: chain).publicKey()
    }

    /// [Non-Cache] Get address for index
    public func address(index: UInt32, chain: Chain) -> BitcoinAddress {
        return pubKey(index: index, chain: chain).toBitcoinAddress()
    }

    /// Increment external index and update privkey/pubkey/address cache.
    public func incrementExternalIndex(by value: UInt32) {
        let newIndex: UInt32 = externalIndex + value
        let newPrivKeys: [PrivateKey] = (externalIndex + 1...newIndex).map { privKey(index: $0, chain: .external) }
        let newPubKeys: [PublicKey] = newPrivKeys.map { $0.publicKey() }
        let newAddresses: [BitcoinAddress] = newPubKeys.map { $0.toBitcoinAddress() }
        externalIndex += value
        externalPrivKeys += newPrivKeys
        externalPubKeys += newPubKeys
        externalAddresses += newAddresses
    }

    /// Increment internal index and update privkey/pubkey/address cache.
    public func incrementInternalIndex(by value: UInt32) {
        let newIndex: UInt32 = internalIndex + value
        let newPrivKeys: [PrivateKey] = (internalIndex + 1...newIndex).map { privKey(index: $0, chain: .internal) }
        let newPubKeys: [PublicKey] = newPrivKeys.map { $0.publicKey() }
        let newAddresses: [BitcoinAddress] = newPubKeys.map { $0.toBitcoinAddress() }
        internalIndex += value
        internalPrivKeys += newPrivKeys
        internalPubKeys += newPubKeys
        internalAddresses += newAddresses
    }

    // MARK: - Deprecated properties
    @available(*, unavailable)
    public var transactions: [Transaction] {
        return []
    }

    @available(*, unavailable)
    public var unspentTransactions: [Transaction] {
        return []
    }

    @available(*, unavailable)
    public var balance: UInt64 {
        return 0
    }

    // MARK: - Deprecated methods
    // External Addresses & Keys (Receive Addresses & Keys)
    @available(*, unavailable, renamed: "address")
    public func receiveAddress() throws -> Address {
        return address(index: externalIndex, chain: .external)
    }

    @available(*, unavailable, message: "Use address(_ index: UInt32, chain: Chain) instead")
    public func receiveAddress(index: UInt32) throws -> Address {
        return address(index: index, chain: .external)
    }

    @available(*, unavailable, renamed: "pubKey")
    public func publicKey(index: UInt32) throws -> PublicKey {
        return pubKey(index: index, chain: .external)
    }

    @available(*, unavailable, renamed: "privKey")
    public func privateKey(index: UInt32) throws -> PrivateKey {
        return privKey(index: index, chain: .external)
    }

    @available(*, unavailable, renamed: "xpubKey")
    public func extendedPublicKey(index: UInt32) throws -> HDPublicKey {
        return xpubKey(index: index, chain: .external)
    }

    @available(*, unavailable, renamed: "xprivKey")
    public func extendedPrivateKey(index: UInt32) throws -> HDPrivateKey {
        return xprivKey(index: index, chain: .external)
    }

    // MARK: - Internal Addresses & Keys (Change Addresses& Keys)
    @available(*, unavailable, message: "Use address(_ index: UInt32, chain: Chain) instead")
    public func changeAddress(index: UInt32) throws -> Address {
        return address(index: index, chain: .internal)
    }

    @available(*, unavailable, renamed: "pubKey")
    public func changePublicKey(index: UInt32) throws -> PublicKey {
        return pubKey(index: index, chain: .internal)
    }

    @available(*, unavailable, renamed: "privKey")
    public func changePrivateKey(index: UInt32) throws -> PrivateKey {
        return privKey(index: index, chain: .internal)
    }

    @available(*, unavailable, renamed: "xpubKey")
    public func changeExtendedPublicKey(index: UInt32) throws -> HDPublicKey {
        return xpubKey(index: index, chain: .internal)
    }

    @available(*, unavailable, renamed: "xprivKey")
    public func changeExtendedPrivateKey(index: UInt32) throws -> HDPrivateKey {
        return xprivKey(index: index, chain: .internal)
    }
}
