//
//  OpCodeProtocol.swift
//  BitcoinCashKit
//
//  Created by Shun Usami on 2018/07/26.
//  Copyright © 2018 BitcoinCashKit developers. All rights reserved.
//

import Foundation

public protocol OpCodeProtocol {
    var name: String { get }
    var value: UInt8 { get }

    func isEnabled() -> Bool
    func execute(_ context: ScriptExecutionContext) throws
}

extension OpCodeProtocol {
    public func isEnabled() -> Bool {
        return true
    }
    public func prepareExecute(_ context: ScriptExecutionContext) throws {
        context.opCount += 1
        guard context.opCount <= BTC_MAX_OPS_PER_SCRIPT else {
            throw OpCodeExecutionError.error("Exceeded the allowed number of operations per script.")
        }
    }

    public func execute(_ context: ScriptExecutionContext) throws {
        throw OpCodeExecutionError.notImplemented
    }
}

enum OpCodeExecutionError: Error {
    case notImplemented
    case error(String)
    case opcodeRequiresItemsOnStack(Int)
}

// ==
public func == (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Bool {
    return lhs.value == rhs.value
}
public func == <Other: BinaryInteger>(lhs: OpCodeProtocol, rhs: Other) -> Bool {
    return lhs.value == rhs
}
public func == <Other: BinaryInteger>(lhs: Other, rhs: OpCodeProtocol) -> Bool {
    return lhs == rhs.value
}

// !=
public func != (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Bool {
    return lhs.value != rhs.value
}
public func != <Other: BinaryInteger>(lhs: OpCodeProtocol, rhs: Other) -> Bool {
    return lhs.value != rhs
}
public func != <Other: BinaryInteger>(lhs: Other, rhs: OpCodeProtocol) -> Bool {
    return lhs != rhs.value
}

// >
public func > (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Bool {
    return lhs.value > rhs.value
}
public func > <Other: BinaryInteger>(lhs: OpCodeProtocol, rhs: Other) -> Bool {
    return lhs.value > rhs
}
public func > <Other: BinaryInteger>(lhs: Other, rhs: OpCodeProtocol) -> Bool {
    return lhs > rhs.value
}

// <
public func < (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Bool {
    return lhs.value < rhs.value
}
public func < <Other: BinaryInteger>(lhs: OpCodeProtocol, rhs: Other) -> Bool {
    return lhs.value < rhs
}
public func < <Other: BinaryInteger>(lhs: Other, rhs: OpCodeProtocol) -> Bool {
    return lhs < rhs.value
}

// >=
public func >= (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Bool {
    return lhs.value >= rhs.value
}

// <=
public func <= (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Bool {
    return lhs.value <= rhs.value
}

// ...
public func ... (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Range<UInt8> {
    return Range(lhs.value...rhs.value)
}

// ~=
public func ~= (pattern: OpCodeProtocol, op: OpCodeProtocol) -> Bool {
    return pattern == op
}
public func ~= (pattern: Range<UInt8>, op: OpCodeProtocol) -> Bool {
    return pattern ~= op.value
}
