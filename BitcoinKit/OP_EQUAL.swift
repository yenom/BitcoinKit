//
//  OP_EQUAL.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

// Returns 1 if the inputs are exactly equal, 0 otherwise.
public struct OpEqual: OpCodeProtocol {
    public var value: UInt8 { return 0x87 }
    public var name: String { return "OP_EQUAL" }

    // input : x1 x2
    // output : true / false
    public func execute(_ context: ScriptExecutionContext) throws {
        try prepareExecute(context)
        guard context.stack.count >= 2 else {
            throw OpCodeExecutionError.opcodeRequiresItemsOnStack(2)
        }

        let x1 = context.stack.popLast()!
        let x2 = context.stack.popLast()!
        let equal: Bool = x1 == x2
        context.pushToStack(equal)
    }
}
