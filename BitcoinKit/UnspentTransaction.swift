//
//  UnspentTransaction.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/08.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public struct UnspentTransaction {
    public let output: TransactionOutput
    public let outpoint: TransactionOutPoint

    public init(output: TransactionOutput, outpoint: TransactionOutPoint) {
        self.output = output
        self.outpoint = outpoint
    }
}
