//
//  OP_0.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinCashKit developers. All rights reserved.
//

import Foundation

// An empty array of bytes is pushed onto the stack. (This is not a no-op: an item is added to the stack.)
public struct Op0: OpCodeProtocol {
    public var value: UInt8 { return 0x00 }
    public var name: String { return "OP_0" }

    // input : -
    // output : n
    public func execute(_ context: ScriptExecutionContext) throws {
        try prepareExecute(context)
        try context.pushToStack(Data())
    }
}
