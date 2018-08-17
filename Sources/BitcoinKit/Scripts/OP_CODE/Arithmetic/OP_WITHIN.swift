//
//  OP_WITHIN.swift
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

// Returns 1 if x is within the specified range (left-inclusive), 0 otherwise.
public struct OpWithin: OpCodeProtocol {
    public var value: UInt8 { return 0xa5 }
    public var name: String { return "OP_WITHIN" }

    // (x1 min max -- out)
     public func mainProcess(_ context: ScriptExecutionContext) throws {
        try context.assertStackHeightGreaterThanOrEqual(3)

        let x = try context.number(at: -3)
        let minValue = try context.number(at: -2)
        let maxValue = try context.number(at: -1)

        context.stack.removeLast()
        context.stack.removeLast()
        context.stack.removeLast()
        context.pushToStack(minValue <= x && x < maxValue)
    }
}
