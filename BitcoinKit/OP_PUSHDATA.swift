//
//  OP_PUSHDATA.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public class OpPushData1: OpCode {
    override public var value: UInt8 { return 0x4c }
    override public var name: String { return "OP_PUSHDATA1" }
}
public class OpPushData2: OpCode {
    override public var value: UInt8 { return 0x4d }
    override public var name: String { return "OP_PUSHDATA2" }
}
public class OpPushData4: OpCode {
    override public var value: UInt8 { return 0x4e }
    override public var name: String { return "OP_PUSHDATA4" }
}
