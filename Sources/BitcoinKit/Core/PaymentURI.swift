//
//  PaymentURI.swift
//
//  Copyright © 2018 Kishikawa Katsumi
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
