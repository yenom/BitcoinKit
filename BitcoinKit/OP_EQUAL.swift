//
//  OP_EQUAL.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public class OpEqual: OpCode {
    override public var value: UInt8 { return 0x87 }
    override public var name: String { return "OP_EQUAL" }

    override public func execute(_ context: ScriptExecutionContext) throws {
        try super.execute(context)
        // (x1 x2 - bool)
        guard context.stack.count >= 2 else {
            throw ScriptMachineError.opcodeRequiresItemsOnStack(2)
        }

        let x1 = context.stack.popLast()!
        let x2 = context.stack.popLast()!
        let equal: Bool = x1 == x2
        context.pushToStack(equal)
    }
}
