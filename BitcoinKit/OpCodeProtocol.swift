//
//  OpCodeProtocol.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/26.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public protocol OpCodeProtocol {
    var name: String { get }
    var value: UInt8 { get }

    func isEnabled() -> Bool
    func execute(_ context: ScriptExecutionContext) throws
}

extension OpCodeProtocol {
    // ==
    static func == <Other: BinaryInteger>(lhs: Self, rhs: Other) -> Bool {
        return lhs.value == rhs
    }
    static func == <Other: BinaryInteger>(lhs: Other, rhs: Self) -> Bool {
        return rhs == rhs.value
    }

    // !=
    static func != <Other: BinaryInteger>(lhs: Self, rhs: Other) -> Bool {
        return lhs.value != rhs
    }
    static func != <Other: BinaryInteger>(lhs: Other, rhs: Self) -> Bool {
        return rhs != rhs.value
    }

    // <
    static func < <Other: BinaryInteger>(lhs: Self, rhs: Other) -> Bool {
        return lhs.value < rhs
    }
    static func < <Other: BinaryInteger>(lhs: Other, rhs: Self) -> Bool {
        return lhs < rhs.value
    }

    // >
    static func > <Other: BinaryInteger>(lhs: Self, rhs: Other) -> Bool {
        return lhs.value > rhs
    }
    static func > <Other: BinaryInteger>(lhs: Other, rhs: Self) -> Bool {
        return lhs > rhs.value
    }

    // <=
    static func <= <Other: BinaryInteger>(lhs: Self, rhs: Other) -> Bool {
        return lhs.value <= rhs
    }
    static func <= <Other: BinaryInteger>(lhs: Other, rhs: Self) -> Bool {
        return lhs <= rhs.value
    }

    // >=
    static func >= <Other: BinaryInteger>(lhs: Self, rhs: Other) -> Bool {
        return lhs.value >= rhs
    }
    static func >= <Other: BinaryInteger>(lhs: Other, rhs: Self) -> Bool {
        return lhs >= rhs.value
    }
}
