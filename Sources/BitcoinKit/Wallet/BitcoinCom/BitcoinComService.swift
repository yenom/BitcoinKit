//
//  BitcoinComService.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/18.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

final public class BitcoinComService {
    internal let userDefaults: UserDefaults = UserDefaults.defaultWalletDataStore
    enum UserDefaultsKey: String {
        case utxos, transactions
    }

    public init() {}

}
