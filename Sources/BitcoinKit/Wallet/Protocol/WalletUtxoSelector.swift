//
//  WalletUtxoSelector.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/18.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

public protocol WalletUtxoSelector {
    func select(from utxos: [UnspentTransaction], targetValue: UInt64) throws -> (utxos: [UnspentTransaction], fee: UInt64)
}
