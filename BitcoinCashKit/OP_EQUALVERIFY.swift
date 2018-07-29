//
//  OP_EQUALVERIFY.swift
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

// Same as OP_EQUAL, but runs OP_VERIFY afterward.
public struct OpEqualVerify: OpCodeProtocol {
    public var value: UInt8 { return 0x88 }
    public var name: String { return "OP_EQUALVERIFY" }

    // input : x1 x2
    // output : - / fail
    public func execute(_ context: ScriptExecutionContext) throws {
        try prepareExecute(context)
        print("stack: \(context.stack.map { $0.hex }.joined(separator: " "))")
        // (x1 x2 - bool)
        guard context.stack.count >= 2 else {
            throw OpCodeExecutionError.opcodeRequiresItemsOnStack(2)
        }

        let x1 = context.stack.popLast()!
        let x2 = context.stack.popLast()!
        let equal: Bool = x1 == x2
        context.pushToStack(equal)

        guard equal else {
            throw OpCodeExecutionError.error("OP_EQUALVERIFY failed.")
        }
        context.stack.removeLast()
    }
}
