//
//  BitcoinComService.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/18.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

final public class BitcoinComService {
    public static let shared: BitcoinComService = BitcoinComService(userDefaults: UserDefaults.defaultWalletDataStore)
    internal let userDefaults: UserDefaults
    enum UserDefaultsKey: String {
        case utxos, transactions
    }

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}
