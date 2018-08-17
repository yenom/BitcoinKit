//
//  OP_SPLIT.swift
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

// Split the operand at the given position.
public struct OpSplit: OpCodeProtocol {
    public var value: UInt8 { return 0x7f }
    public var name: String { return "OP_SPLIT" }

    // input : in position
    // output : x1 x2
    public func mainProcess(_ context: ScriptExecutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(2)
        let data: Data = context.data(at: -2)

        // Make sure the split point is apropriate.
        let position: Int32 = try context.number(at: -1)
        guard position <= data.count else {
            throw OpCodeExecutionError.error("Invalid OP_SPLIT range")
        }

        let n1: Data = data.subdata(in: Range(0..<Int(position)))
        let n2: Data = data.subdata(in: Range(Int(position)..<data.count))

        // Replace existing stack values by the new values.
        context.stack[context.stack.count - 2] = n1
        context.stack[context.stack.count - 1] = n2
    }
}
