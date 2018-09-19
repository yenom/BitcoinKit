//
//  StandardAddressProvider.swift
//
//  Copyright © 2018 BitcoinKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public struct StandardAddressProvider: AddressProvider {
    public static let shared: StandardAddressProvider = StandardAddressProvider(userDefaults: UserDefaults.bitcoinKit)
    internal let userDefaults: UserDefaults
    enum UserDefaultsKey: String {
        case cashaddrs
    }

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    public func reload(keys: [PrivateKey], completion: (([Address]) -> Void)?) {
        let addresses: [Cashaddr] = keys.map { $0.publicKey().toCashaddr() }
        let data = try? JSONEncoder().encode(addresses)
        userDefaults.set(data, forKey: UserDefaultsKey.cashaddrs.rawValue)
        completion?(addresses)
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
