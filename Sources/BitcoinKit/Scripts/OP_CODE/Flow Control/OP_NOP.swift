//
//  OP_NOP.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/08/08.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

// do nothing
public struct OpNop: OpCodeProtocol {
    public var value: UInt8 { return 0x61 }
    public var name: String { return "OP_NOP" }

    public func mainProcess(_ context: ScriptExecutionContext) throws {
        // do nothing
    }
}
