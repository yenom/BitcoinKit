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
    public let address: BitcoinAddress
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

    // swiftlint:disable:next cyclomatic_complexity
    public init(_ string: String) throws {
        guard let components = URLComponents(string: string),
            let scheme = components.scheme,
            scheme.lowercased() == "bitcoin",
            let url = components.url else {
            throw PaymentURIError.invalid
        }
        self.uri = url
        if let cashaddr = try? BitcoinAddress(cashaddr: scheme + components.path) {
            self.address = cashaddr
        } else if let legacy = try? BitcoinAddress(legacy: components.path) {
            self.address = legacy
        } else {
            throw PaymentURIError.malformed(.address)
        }

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
            switch Keys(rawValue: queryItem.name) {
            case .some(.label):
                label = queryItem.value
            case .some(.message):
                message = queryItem.value
            case .some(.amount):
                guard let v = queryItem.value, let value = Decimal(string: v) else {
                    throw PaymentURIError.malformed(.amount)
                }
                amount = value
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
