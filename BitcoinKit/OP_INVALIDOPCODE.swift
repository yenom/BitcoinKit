//
//  OP_INVALIDOPCODE.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public struct OpInvalidOpCode: OpCodeProtocol {
    public var value: UInt8 { return 0xff }
    public var name: String { return "OP_INVALIDOPCODE" }
}
