//
//  OP_VERNOTIF.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/08/08.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

public struct OpVerNotIf: OpCodeProtocol {
    public var value: UInt8 { return 0x66 }
    public var name: String { return "OP_VERNOTIF" }

    public func mainProcess(_ context: ScriptExecutionContext) throws {
        throw OpCodeExecutionError.error("OP_VERNOTIF should not be executed.")
    }
}
