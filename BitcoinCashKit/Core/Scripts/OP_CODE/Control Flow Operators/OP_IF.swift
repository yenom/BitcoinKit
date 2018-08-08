//
//  OP_IF.swift
//  BitcoinCashKit
//
//  Created by Shun Usami on 2018/08/08.
//  Copyright © 2018 BitcoinCashKit developers. All rights reserved.
//

import Foundation

public struct OpIf: OpCodeProtocol {
    public var value: UInt8 { return 0x63 }
    public var name: String { return "OP_IF" }
    
    public func mainProcess(_ context: ScriptExecutionContext) throws {
    }
}
