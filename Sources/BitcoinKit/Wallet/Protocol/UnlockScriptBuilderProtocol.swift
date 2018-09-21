//
//  UnlockScriptBuilderProtocol.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/21.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

public typealias SigKeyPair = (signature: Data, key: PublicKey)

public protocol UnlockScriptBuilderProtocol {
    func build(pairs: [SigKeyPair]) -> Script
}
