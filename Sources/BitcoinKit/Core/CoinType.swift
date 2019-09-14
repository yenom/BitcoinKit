//
//  CoinType.swift
//  BitcoinKit
//
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
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

/// Registered coin types for usage in level 2 of BIP44 described in chapter "Coin type".
public enum CoinType {
    case BCH, BTC, testnet
    /// BIP44 cointype value
    public var index: UInt32 { return entity.index }
    /// Coin symbol
    public var symbol: String { return entity.symbol }
    /// Coin name
    public var name: String { return entity.name }

    private var entity: CoinTypeEntity {
        switch self {
        case .BCH: return .BCH
        case .BTC: return .BTC
        case .testnet: return .testnet
        }
    }
}

public struct CoinTypeEntity {
    public let index: UInt32
    public let symbol: String
    public let name: String

    public init(_ index: UInt32, _ symbol: String, _ name: String) {
        self.index = index
        self.symbol = symbol
        self.name = name
    }

    static let BTC = CoinTypeEntity(0, "BTC", "Bitcoin")
    static let testnet = CoinTypeEntity(1, "", "Testnet (all coins)")
    static let BCH = CoinTypeEntity(145, "BCH", "Bitcoin Cash")
}

extension CoinTypeEntity: Equatable {
    public static func == (lhs: CoinTypeEntity, rhs: CoinTypeEntity) -> Bool {
        return lhs.index == rhs.index
            && lhs.symbol == rhs.symbol
            && lhs.name == rhs.name
    }
}
