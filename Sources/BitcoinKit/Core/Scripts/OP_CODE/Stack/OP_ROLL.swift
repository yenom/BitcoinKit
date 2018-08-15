//
//  OP_ROLL.swift
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

// The item n back in the stack is moved to the top.
public struct OpRoll: OpCodeProtocol {
    public var value: UInt8 { return 0x7a }
    public var name: String { return "OP_ROLL" }

    // input : xn ... x2 x1 x0 <n>
    // output : ... x2 x1 x0 xn
    public func mainProcess(_ context: ScriptExecutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let n: Int32 = try context.number(at: -1)
        context.stack.removeLast()
        guard n >= 0 else {
            throw OpCodeExecutionError.error("\(name): n should be greater than or equal to 0.")
        }
        let index: Int = Int(n + 1)
        try context.assertStackHeightGreaterThanOrEqual(index)
        let count: Int = context.stack.count
        let xn: Data = context.stack.remove(at: count - index)
        context.stack.append(xn)
    }
}
