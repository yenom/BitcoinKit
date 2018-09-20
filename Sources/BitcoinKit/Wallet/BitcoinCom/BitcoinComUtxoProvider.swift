//
//  BitcoinComUtxoProvider.swift
//
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

final public class BitcoinComUtxoProvider: UtxoProvider {
    private let endpoint: ApiEndPoint.BitcoinCom
    private let dataStore: BitcoinKitDataStoreProtocol
    public init(network: Network, dataStore: BitcoinKitDataStoreProtocol) {
        self.endpoint = ApiEndPoint.BitcoinCom(network: network)
        self.dataStore = dataStore
    }

    // GET API: reload utxos
    public func reload(addresses: [Address], completion: (([UnspentTransaction]) -> Void)?) {
        let url = endpoint.getUtxoURL(with: addresses)
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else {
                print("data is nil.")
                completion?([])
                return
            }
            guard let response = try? JSONDecoder().decode([[BitcoinComUtxoModel]].self, from: data) else {
                print("decode failed.")
                completion?([])
                return
            }
            self?.dataStore.setData(data, forKey: .utxos)
            completion?(response.joined().asUtxos())
        }
        task.resume()
    }

    // List utxos
    public var cached: [UnspentTransaction] {
        guard let data = dataStore.getData(forKey: .utxos) else {
            print("data is  nil")
            return []
        }

        guard let response = try? JSONDecoder().decode([[BitcoinComUtxoModel]].self, from: data) else {
            print("data cannot be decoded to response")
            return []
        }
        return response.joined().asUtxos()
    }
}

private extension Sequence where Element == BitcoinComUtxoModel {
    func asUtxos() -> [UnspentTransaction] {
        return compactMap { $0.asUtxo() }
    }
}

// MARK: - GET Unspent Transaction Outputs
private struct BitcoinComUtxoModel: Codable {
    let txid: String
    let vout: UInt32
    let scriptPubKey: String
    let amount: Decimal
    let satoshis: UInt64
    let height: Int?
    let confirmations: Int
    let legacyAddress: String
    let cashAddress: String

    func asUtxo() -> UnspentTransaction? {
        guard let lockingScript = Data(hex: scriptPubKey), let txidData = Data(hex: String(txid)) else { return nil }
        let txHash: Data = Data(txidData.reversed())
        let output = TransactionOutput(value: satoshis, lockingScript: lockingScript)
        let outpoint = TransactionOutPoint(hash: txHash, index: vout)
        return UnspentTransaction(output: output, outpoint: outpoint)
    }
}
