//
//  OpCodeProtocol.swift
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

public protocol OpCodeProtocol {
    var name: String { get }
    var value: UInt8 { get }

    func isEnabled() -> Bool
    func mainProcess(_ context: ScriptExecutionContext) throws
}

extension OpCodeProtocol {
    public func isEnabled() -> Bool {
        return true
    }
    private func preprocess(_ context: ScriptExecutionContext) throws {
        if value > OpCode.OP_16 {
            try context.incrementOpCount()
        }

        guard isEnabled() else {
            throw OpCodeExecutionError.disabled
        }

        guard !(context.shouldExecute && 0 <= value && value <= OpCode.OP_PUSHDATA4.value) else {
            throw OpCodeExecutionError.error("PUSHDATA OP_CODE should not be executed.")
        }
    }

    public func mainProcess(_ context: ScriptExecutionContext) throws {
        throw OpCodeExecutionError.notImplemented("[\(name)(\(value))]")
    }

    public func execute(_ context: ScriptExecutionContext) throws {
        try preprocess(context)
        guard context.shouldExecute || (OpCode.OP_IF <= self && self <= OpCode.OP_ENDIF) else {
            if context.verbose {
                print("[SKIP execution :  \(name)(\(value))]\n" + String(repeating: "-", count: 100))
            }
            return
        }
        if context.verbose {
            print("OpCount : \(context.opCount)\n[pre execution : \(name)(\(value))]\n\(context)")
        }

        try mainProcess(context)

        if context.verbose {
            print("[post execution : \(name)(\(value))]\n\(context)\n" + String(repeating: "-", count: 100))
        }
    }
}

public enum OpCodeExecutionError: Error {
    case notImplemented(String)
    case error(String)
    case opcodeRequiresItemsOnStack(Int)
    case invalidBignum
    case disabled
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
