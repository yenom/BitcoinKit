//
//  PaymentURI.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/11.
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 Shun Usami
//  Copyright © 2018 BitcoinCashKit developers
//  Licensed under the Apache License, Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  This file has been modified by the BitcoinCashKit developers for the BitcoinCashKit project.
//  The original file was from the bitcoinj project (https://github.com/kishikawakatsumi/BitcoinKit).
//

import Foundation

public struct PaymentURI {
    public let address: Address
    public let label: String?
    public let message: String?
    public let amount: Decimal?
    public let others: [String: String]
    public let uri: URL

    public enum Keys: String {
        case address
        case label
        case message
        case amount
    }

    public init(_ string: String) throws {
        guard let components = URLComponents(string: string), let scheme = components.scheme, scheme.lowercased() == "bitcoin" else {
            throw PaymentURIError.invalid
        }
        guard let address = try? AddressFactory.create(components.path) else {
            throw PaymentURIError.malformed(.address)
        }
        self.address = address
        self.uri = components.url!

        guard let queryItems = components.queryItems else {
            self.label = nil
            self.message = nil
            self.amount = nil
            self.others = [:]
            return
        }

        var label: String?
        var message: String?
        var amount: Decimal?
        var others = [String: String]()
        for queryItem in queryItems {
            switch queryItem.name {
            case Keys.label.rawValue:
                label = queryItem.value
            case Keys.message.rawValue:
                message = queryItem.value
            case Keys.amount.rawValue:
                if let v = queryItem.value, let value = Decimal(string: v) {
                    amount = value
                } else {
                    throw PaymentURIError.malformed(.amount)
                }
            default:
                if let value = queryItem.value {
                    others[queryItem.name] = value
                }
            }
        }
        self.label = label
        self.message = message
        self.amount = amount
        self.others = others
    }
}

enum PaymentURIError: Error {
    case invalid
    case malformed(PaymentURI.Keys)
}
