//
//  WalletDataStoreProtocol.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/17.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

// MARK: - WalletDataStoreProtocol
public protocol WalletDataStoreProtocol {
    func getString(forKey key: String) -> String?
    func setString(_ value: String, forKey key: String)
}

internal enum WalletDataStoreKey: String {
    case wif, internalIndex, extenralIndex
}

internal extension WalletDataStoreProtocol {
    internal func getString(forKey key: WalletDataStoreKey) -> String? {
        return getString(forKey: key.rawValue)
    }
    internal func setString(_ value: String, forKey key: WalletDataStoreKey) {
        setString(value, forKey: key.rawValue)
    }
}

// MARK: - UserDefaults
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
