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

final public class Wallet {
    public let privateKey: PrivateKey
    public let publicKey: PublicKey

    public let network: Network
    public var walletDataStore: WalletDataStoreProtocol = UserDefaults.defaultWalletDataStore
    public var utxoProvider: WalletUtxoProvider = BitcoinComService.shared
    public var transactionProvider: WalletTransactionProvider = BitcoinComService.shared
    public var transactionBroadcaster: WalletTransactionBroadcaster = BitcoinComService.shared

    public init?(walletDataStore dataStore: WalletDataStoreProtocol = UserDefaults.defaultWalletDataStore) {
        self.walletDataStore = dataStore
        guard let wif = walletDataStore.getString(forKey: .wif) else { return nil }
        do {
            self.privateKey = try PrivateKey(wif: wif)
            self.publicKey = privateKey.publicKey()
            self.network = privateKey.network
        } catch {
            return nil
        }
    }
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

    public func save() {
        walletDataStore.setString(privateKey.toWIF(), forKey: .wif)
    }

    public func reloadBalance(completion: (([UnspentTransaction]) -> Void)? = nil) {
        utxoProvider.reload(completion: completion)
    }

    public func balance() -> UInt64 {
        return utxoProvider.list().reduce(UInt64()) { $0 + $1.output.value }
    }

    public func transactions() -> [Transaction] {
        return transactionProvider.list()
    }

    public func reloadTransactions(completion: (([Transaction]) -> Void)? = nil) {
        transactionProvider.reload(completion: completion)
    }

    public func broadcast(rawtx: String, completion: ((_ txid: String?) -> Void)? = nil) {
        transactionBroadcaster.post(rawtx, completion: completion)
    }
}
