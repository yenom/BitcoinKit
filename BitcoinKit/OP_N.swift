//
//  OP_N.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public class OpN: OpCode {
    override public var value: UInt8 { return 0x50 + n }
    override public var name: String { return "OP_\(n)" }
    private let n: UInt8
    internal init(_ n: UInt8) {
        guard (1...16).contains(n) else {
            fatalError("OP_N can be initialized with N between 1 and 16. \(n) is not valid.")
        }
        self.n = n
        super.init()
    }
}
