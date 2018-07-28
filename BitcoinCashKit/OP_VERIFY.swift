//
//  OP_VERIFY.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinCashKit developers. All rights reserved.
//

import Foundation

// Marks transaction as invalid if top stack value is not true. The top stack value is removed.
public struct OpVerify: OpCodeProtocol {
    public var value: UInt8 { return 0x69 }
    public var name: String { return "OP_VERIFY" }

    // input : true / false
    // output : - / fail
    public func execute(_ context: ScriptExecutionContext) throws {
        try prepareExecute(context)
        guard context.stack.count >= 1 else {
            throw OpCodeExecutionError.opcodeRequiresItemsOnStack(1)
        }
        guard context.bool(at: -1) else {
            throw OpCodeExecutionError.error("OP_VERIFY failed.")
        }
        context.stack.removeLast()
    }
}
