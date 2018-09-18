//
//  UserDefaults+WalletDataStoreProtocol.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/17.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

extension UserDefaults: WalletDataStoreProtocol {
    public static var defaultWalletDataStore: UserDefaults {
        return UserDefaults(suiteName: "BitcoinKit.WalletDataStore")!
    }
    public func getString(forKey key: String) -> String? {
        return string(forKey: key)
    }

    public func setString(_ value: String, forKey key: String) {
        setValue(value, forKey: key)
        synchronize()
    }
}
