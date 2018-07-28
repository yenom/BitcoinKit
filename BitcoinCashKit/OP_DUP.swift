//
//  OP_DUP.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinCashKit developers. All rights reserved.
//

import Foundation

// Duplicates the top stack item.
public struct OpDuplicate: OpCodeProtocol {
    public var value: UInt8 { return 0x76 }
    public var name: String { return "OP_DUP" }

    // input : x
    // output : x x
    public func execute(_ context: ScriptExecutionContext) throws {
        try prepareExecute(context)
        guard context.stack.count >= 1 else {
            throw OpCodeExecutionError.opcodeRequiresItemsOnStack(1)
        }
        try context.pushToStack(context.data(at: -1))
    }
}
