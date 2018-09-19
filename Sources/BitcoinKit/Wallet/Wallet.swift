//
//  Wallet.swift
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

// Some of default parameters of Wallet class [utxoProvider, transactionHistoryProvider, transactionBroadcaster] are only compatible with Bitcoin Cash(BCH).
// They are using rest.bitcoin.com API endpoints and the endpoints are only available for Bitcoin Cash(BCH).
// If you want to use BTC, please implement
final public class Wallet {
    public let privateKey: PrivateKey
    public let publicKey: PublicKey
    public var address: Address { return publicKey.toCashaddr() }

    public let network: Network
    private let walletDataStore: BitcoinKitDataStoreProtocol
    private let addressProvider: AddressProvider
    private let utxoProvider: UtxoProvider
    private let transactionHistoryProvider: TransactionHistoryProvider
    private let transactionBroadcaster: TransactionBroadcaster
    private let utxoSelector: UtxoSelector
    private let transactionBuilder: TransactionBuilder
    private let transactionSigner: TransactionSigner

    public init(privateKey: PrivateKey,
                dataStore: BitcoinKitDataStoreProtocol = UserDefaults.bitcoinKit,
                addressProvider: AddressProvider? = nil,
                utxoProvider: UtxoProvider? = nil,
                transactionHistoryProvider: TransactionHistoryProvider? = nil,
                transactionBroadcaster: TransactionBroadcaster? = nil,
                utxoSelector: UtxoSelector = StandardUtxoSelector(),
                transactionBuilder: TransactionBuilder = StandardTransactionBuilder(),
                transactionSigner: TransactionSigner = StandardTransactionSigner()) {
        let network = privateKey.network
        self.privateKey = privateKey
        self.publicKey = privateKey.publicKey()
        self.network = network

        let userDefaults: BitcoinKitDataStoreProtocol = UserDefaults.bitcoinKit

        self.addressProvider = addressProvider
            ?? StandardAddressProvider(keys: [privateKey])
        self.utxoProvider = utxoProvider
            ?? BitcoinComUtxoProvider(network: network, dataStore: userDefaults)
        self.transactionHistoryProvider = transactionHistoryProvider
            ?? BitcoinComTransactionHistoryProvider(network: network, dataStore: userDefaults)
        self.transactionBroadcaster = transactionBroadcaster
            ?? BitcoinComTransactionBroadcaster(network: network)

        self.walletDataStore = dataStore
        self.utxoSelector = utxoSelector
        self.transactionBuilder = transactionBuilder
        self.transactionSigner = transactionSigner
    }

    public convenience init?(dataStore: BitcoinKitDataStoreProtocol = UserDefaults.bitcoinKit) {
        guard let wif = dataStore.getString(forKey: .wif), let privateKey = try? PrivateKey(wif: wif) else {
            return nil
        }
        self.init(privateKey: privateKey, dataStore: dataStore)
    }

    public convenience init?(wif: String) {
        guard let privateKey = try? PrivateKey(wif: wif) else {
            return nil
        }
        self.init(privateKey: privateKey)
    }

    public func save() {
        walletDataStore.setString(privateKey.toWIF(), forKey: .wif)
    }

    public func addresses() -> [Address] {
        let cache = addressProvider.list()
        guard !cache.isEmpty else {
            addressProvider.reload(keys: [privateKey], completion: nil)
            return [address]
        }
        return cache
    }

    public func reloadBalance(completion: (([UnspentTransaction]) -> Void)? = nil) {
        utxoProvider.reload(addresses: addresses(), completion: completion)
    }

    public func balance() -> UInt64 {
        return utxoProvider.cached.sum()
    }

    public func utxos() -> [UnspentTransaction] {
        return utxoProvider.cached
    }

    public func transactions() -> [Transaction] {
        return transactionHistoryProvider.cached
    }

    public func reloadTransactions(completion: (([Transaction]) -> Void)? = nil) {
        transactionHistoryProvider.reload(addresses: addresses(), completion: completion)
    }

    public func send(to toAddress: Address, amount: UInt64, completion: ((_ txid: String?) -> Void)? = nil) throws {
        let utxos = utxoProvider.cached
        let (utxosToSpend, fee) = try utxoSelector.select(from: utxos, targetValue: amount)
        let totalAmount: UInt64 = utxosToSpend.sum()
        let change: UInt64 = totalAmount - amount - fee
        let destinations: [(Address, UInt64)] = [(toAddress, amount), (address, change)]
        let unsignedTx = try transactionBuilder.build(destinations: destinations, utxos: utxosToSpend)
        let signedTx = try transactionSigner.sign(unsignedTx, with: [privateKey])

        let rawtx = signedTx.serialized().hex
        transactionBroadcaster.post(rawtx, completion: completion)
    }
}

internal extension Sequence where Element == UnspentTransaction {
    func sum() -> UInt64 {
        return reduce(UInt64()) { $0 + $1.output.value }
    }
}
