//
//  OP_VERIFY.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public class OpVerify: OpCode {
    override public var value: UInt8 { return 0x69 }
    override public var name: String { return "OP_VERIFY" }

    override public func execute(_ context: ScriptExecutionContext) throws {
        try super.execute(context)
        // (true -- ) or
        // (false -- false) and return
        guard context.stack.count >= 1 else {
            throw ScriptMachineError.opcodeRequiresItemsOnStack(1)
        }
        guard context.bool(at: -1) else {
            throw ScriptMachineError.error("OP_VERIFY failed.")
        }
        context.stack.removeLast()
    }
}
