//
//  AddressProvider.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/18.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

public protocol AddressProvider {
    // GET API: reload utxos
    func reload(keys: [PrivateKey], completion: (([Address]) -> Void)?)

    // List utxos
    func list() -> [Address]
}
