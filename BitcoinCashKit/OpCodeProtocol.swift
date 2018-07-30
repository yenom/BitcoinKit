//
//  OpCodeProtocol.swift
//
//  Copyright © 2018 BitcoinCashKit developers
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
        try context.incrementOpCount()
        // if context.verbose == true, print stacks and so on...
    }

    public func execute(_ context: ScriptExecutionContext) throws {
        throw OpCodeExecutionError.notImplemented
    }
}

public enum OpCodeExecutionError: Error {
    case notImplemented
    case error(String)
    case opcodeRequiresItemsOnStack(Int)
    case invalidBignum
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
