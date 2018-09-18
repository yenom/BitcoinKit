//
//  TransactionSigner.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/18.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

public protocol TransactionSigner {
    func sign(_ unsignedTransaction: UnsignedTransaction, with keys: [PrivateKey]) throws -> Transaction
}
