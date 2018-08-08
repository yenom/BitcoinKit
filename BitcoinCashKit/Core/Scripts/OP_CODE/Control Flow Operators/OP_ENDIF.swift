//
//  OP_ENDIF.swift
//  BitcoinCashKit
//
//  Created by Shun Usami on 2018/08/08.
//  Copyright © 2018 BitcoinCashKit developers. All rights reserved.
//

import Foundation

public struct OpEndIf: OpCodeProtocol {
    public var value: UInt8 { return 0x68 }
    public var name: String { return "OP_ENDIF" }

    public func mainProcess(_ context: ScriptExecutionContext) throws {
    }
}
