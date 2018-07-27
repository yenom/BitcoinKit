//
//  OP_0.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public class Op0: OpCode {
    override public var value: UInt8 { return 0x00 }
    override public var name: String { return "OP_0" }
}
