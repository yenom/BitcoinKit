//
//  OP_PUSHDATA.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinCashKit developers. All rights reserved.
//

import Foundation

// The next byte contains the number of bytes to be pushed onto the stack.
public struct OpPushData1: OpCodeProtocol {
    public var value: UInt8 { return 0x4c }
    public var name: String { return "OP_PUSHDATA1" }
}

// The next two bytes contain the number of bytes to be pushed onto the stack in little endian order.
public struct OpPushData2: OpCodeProtocol {
    public var value: UInt8 { return 0x4d }
    public var name: String { return "OP_PUSHDATA2" }
}

// The next four bytes contain the number of bytes to be pushed onto the stack in little endian order.
public struct OpPushData4: OpCodeProtocol {
    public var value: UInt8 { return 0x4e }
    public var name: String { return "OP_PUSHDATA4" }
}
