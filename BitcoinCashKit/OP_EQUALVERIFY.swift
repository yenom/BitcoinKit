//
//  OP_EQUALVERIFY.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
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
