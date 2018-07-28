//
//  OpCodeFactory.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public struct OpCodeFactory {
    public static func get(with value: UInt8) -> OpCodeProtocol {
        guard let item = (OpCode.list.first { $0.value == value }) else {
            return OpCode.OP_INVALIDOPCODE
        }
        return item
    }

    public static func get(with name: String) -> OpCodeProtocol {
        guard let item = (OpCode.list.first { $0.name == name }) else {
            return OpCode.OP_INVALIDOPCODE
        }
        return item
    }

    // Returns OP_1NEGATE, OP_0 .. OP_16 for ints from -1 to 16.
    // Returns OP_INVALIDOPCODE for other ints.
    public static func opcodeForSmallInteger(smallInteger: Int) -> OpCodeProtocol {
        switch smallInteger {
        case -1:
            return OpCode.OP_1NEGATE
        case 0:
            return OpCode.OP_0
        case 1...16:
            return get(with: OpCode.OP_1.value + UInt8(smallInteger - 1))
        default:
            return OpCode.OP_INVALIDOPCODE
        }
    }

    // Converts opcode OP_<N> or OP_1NEGATE to an integer value.
    // If incorrect opcode is given, Int.max is returned.
    public static func smallIntegerFromOpcode(opcode: OpCodeProtocol) -> Int {
        switch opcode {
        case OpCode.OP_1NEGATE:
            return -1
        case OpCode.OP_0:
            return 0
        case (OpCode.OP_1)...(OpCode.OP_16):
            return Int(opcode.value - OpCode.OP_1.value - 1)
        default:
            return Int.max
        }
    }
}
