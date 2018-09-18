//
//  BitcoinComService+WalletTransactionProvider.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/18.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

extension BitcoinComService: WalletTransactionProvider {
    // GET API: reload utxos
    public func reload(completion: (([Transaction]) -> Void)?) {
        let url = URL(string: "https://rest.bitcoin.com/v1/address/transactions/bitcoincash:qzs02v05l7qs5s24srqju498qu55dwuj0cx5ehjm2c")!
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else {
                completion?([])
                return
            }
            guard let response = try? JSONDecoder().decode([BitcoinComTransaction].self, from: data) else {
                completion?([])
                return
            }
            self?.userDefaults.set(data, forKey: UserDefaultsKey.transactions.rawValue)
            self?.userDefaults.synchronize()
            completion?(response.asTransactions())
        }
        task.resume()
    }

    // List utxos
    public func list() -> [Transaction] {
        guard let data = userDefaults.data(forKey: UserDefaultsKey.transactions.rawValue) else {
            print("data is  nil")
            return []
        }

        guard let response = try? JSONDecoder().decode([BitcoinComTransaction].self, from: data) else {
            print("data cannot be decoded to response")
            return []
        }
        return response.asTransactions()
    }

}

private extension Array where Element == BitcoinComTransaction {
    func asTransactions() -> [Transaction] {
        return compactMap { $0.asTransaction() }
    }
}

// MARK: - GET Transactions
private struct BitcoinComTransaction: Codable {
    let txid: String
    let version: UInt32
    let locktime: UInt32
    let vin: [TxIn]
    let vout: [TxOut]
    let blockhash: String
    let blockheight: Int
    let valueOut: Decimal
    let size: Int
    let valueIn: Decimal
    let fees: Decimal

    func asTransaction() -> Transaction? {
        var inputs: [TransactionInput] = []
        var outputs: [TransactionOutput] = []
        for txin in vin {
            guard let input = txin.asTransactionInput() else { return nil }
            inputs.append(input)
        }
        for txout in vout {
            guard let output = txout.asTransactionOutput() else { return nil }
            outputs.append(output)
        }
        return Transaction(version: version, inputs: inputs, outputs: outputs, lockTime: locktime)
    }
}

private struct TxIn: Codable {
    let txid: String
    let vout: UInt32
    let sequence: UInt32
    let scriptSig: ScriptSig
    // let addr: String
    // let valueSat: UInt64
    // let value: Decimal

    // let n: Int
    // let doubleSpentTxID: String?

    func asTransactionInput() -> TransactionInput? {
        guard let signatureScript = Data(hex: scriptSig.hex), let txidData = Data(hex: String(txid)) else { return nil }
        let txHash: Data = Data(txidData.reversed())
        let outpoint = TransactionOutPoint(hash: txHash, index: vout)
        return TransactionInput(previousOutput: outpoint, signatureScript: signatureScript, sequence: sequence)
    }
}

private struct ScriptSig: Codable {
    let hex: String
    // let asm: String
}

private struct TxOut: Codable {
    let value: Decimal
    let scriptPubKey: ScriptPubKey

    // let type: String
    // let n: Int
    // let spentTxId: String?
    // let spentIndex: Int?
    // let spentHeight: Int?

    func asTransactionOutput() -> TransactionOutput? {
        guard let lockingScript = Data(hex: scriptPubKey.hex) else { return nil }
        let int64Value: UInt64 = UInt64((value * 100_000_000).doubleValue)
        return TransactionOutput(value: int64Value, lockingScript: lockingScript)
    }
}

private struct ScriptPubKey: Codable {
    let hex: String
    // let asm: String
    // let addresses: [String]
}

private extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}
