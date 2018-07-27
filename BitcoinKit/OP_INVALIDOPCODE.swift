//
//  OP_INVALIDOPCODE.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public class OpInvalidOpCode: OpCode {
    override public var value: UInt8 { return 0xff }
    override public var name: String { return "OP_INVALIDOPCODE" }

    override public func execute(_ context: ScriptExecutionContext) throws {
        try super.execute(context)
        // do something with context here!
    }
}
