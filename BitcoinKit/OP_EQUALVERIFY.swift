//
//  OP_EQUALVERIFY.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public class OpEqualVerify: OpCode {
    override public var value: UInt8 { return 0x88 }
    override public var name: String { return "OP_EQUALVERIFY" }

    override public func execute(_ context: ScriptExecutionContext) throws {
        try super.execute(context)
        print("stack: \(context.stack.map { $0.hex }.joined(separator: " "))")
        try OpCode.OP_EQUAL.execute(context)
        try OpCode.OP_VERIFY.execute(context)
    }
}
