//
//  OP_NOTIF.swift
//  BitcoinCashKit
//
//  Created by Shun Usami on 2018/08/08.
//  Copyright © 2018 BitcoinCashKit developers. All rights reserved.
//

import Foundation

public struct OpNotIf: OpCodeProtocol {
    public var value: UInt8 { return 0x64 }
    public var name: String { return "OP_NOTIF" }

    public func mainProcess(_ context: ScriptExecutionContext) throws {
        try context.assertStackHeightGreaterThan(1)
        let value = context.bool(at: -1)
        context.stack.removeLast()
        context.conditionStack.append(!value)
    }
}
