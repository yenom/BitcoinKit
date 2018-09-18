//
//  StandardAddressProvider.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/18.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

public struct StandardAddressProvider: AddressProvider {
    public static let shared: StandardAddressProvider = StandardAddressProvider(userDefaults: UserDefaults.defaultWalletDataStore)
    internal let userDefaults: UserDefaults
    enum UserDefaultsKey: String {
        case cashaddrs
    }

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    public func reload(keys: [PrivateKey], completion: (([Address]) -> Void)?) {
        let data = try? JSONEncoder().encode(keys.map { $0.publicKey().toCashaddr() })
        userDefaults.set(data, forKey: UserDefaultsKey.cashaddrs.rawValue)
    }

    public func list() -> [Address] {
        guard let data = userDefaults.data(forKey: UserDefaultsKey.cashaddrs.rawValue) else {
            return []
        }
        do {
            return try JSONDecoder().decode([Cashaddr].self, from: data)
        } catch {
            return []
        }
    }
}

extension Cashaddr: Codable {
    enum CodingKeys: String, CodingKey {
        case string
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let string = try container.decode(String.self, forKey: .string)
        try self.init(string)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.cashaddr, forKey: .string)
    }
}
