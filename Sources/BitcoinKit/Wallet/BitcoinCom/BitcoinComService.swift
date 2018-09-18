//
//  BitcoinComService.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/18.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

final public class BitcoinComService {
    public static let shared: BitcoinComService = BitcoinComService(network: .testnet, userDefaults: UserDefaults.defaultWalletDataStore)!

    public let baseUrl: String
    internal let userDefaults: UserDefaults
    enum UserDefaultsKey: String {
        case utxos, transactions
    }

    public init?(network: Network, userDefaults: UserDefaults) {
        switch network {
        case .testnet:
            self.baseUrl = "https://trest.bitcoin.com/v1/"
        case .mainnet:
            self.baseUrl = "https://rest.bitcoin.com/v1/"
        default:
            return nil
        }
        self.userDefaults = userDefaults
    }
}
