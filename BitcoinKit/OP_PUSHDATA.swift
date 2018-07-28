//
//  OP_PUSHDATA.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public struct OpPushData1: OpCodeProtocol {
    public var value: UInt8 { return 0x4c }
    public var name: String { return "OP_PUSHDATA1" }
}
public struct OpPushData2: OpCodeProtocol {
    public var value: UInt8 { return 0x4d }
    public var name: String { return "OP_PUSHDATA2" }
}
public struct OpPushData4: OpCodeProtocol {
    public var value: UInt8 { return 0x4e }
    public var name: String { return "OP_PUSHDATA4" }
}
