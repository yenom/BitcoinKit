//
//  TransactionBuilder.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/18.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

public protocol TransactionBuilder {
    func build(destinations: [(address: Address, amount: UInt64)], utxos: [UnspentTransaction]) throws -> UnsignedTransaction
}
