//
//  UnspentTransaction.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/08.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public struct UnspentTransaction {
    let output: TransactionOutput
    let outpoint: TransactionOutPoint
}
