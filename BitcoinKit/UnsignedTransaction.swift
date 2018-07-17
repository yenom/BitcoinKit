//
//  UnsignedTransaction.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/08.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public struct UnsignedTransaction {
    public let tx: Transaction
    public let utxos: [UnspentTransaction]

    public init(tx: Transaction, utxos: [UnspentTransaction]) {
        self.tx = tx
        self.utxos = utxos
    }
}
