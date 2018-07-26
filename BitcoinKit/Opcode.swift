//
//  OpCode.swift
//  BitcoinKit
//
//  Created by Akifumi Fujita on 2018/07/09.
//  Copyright © 2018 Akifumi Fujita
//  Copyright © 2018 BitcoinCashKit developers
//  Licensed under the Apache License, Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public class OpCode: OpCodeProtocol {
    public var value: UInt8 { return 0x00 }
    public var name: String { return "" }

    public func isEnabled() -> Bool { return false }
    public func execute(_ context: ScriptExecutionContext) throws {}

    // 1. Operators pushing data on stack.

    // Push 1 byte 0x00 on the stack
    public static let OP_0: OpCode = OpExample()
    public static let OP_FALSE = OP_0

    // Any opcode with value < PUSHDATA1 is a length of the string to be pushed on the stack.
    // So opcode 0x01 is followed by 1 byte of data, 0x09 by 9 bytes and so on up to 0x4b (75 bytes)

    // PUSHDATA<N> opcode is followed by N-byte length of the string that follows.
    public static let OP_PUSHDATA1: OpCode = OpExample() // followed by a 1-byte length of the string to push (allows pushing 0..255 bytes).
    public static let OP_PUSHDATA2: OpCode = OpExample() // followed by a 2-byte length of the string to push (allows pushing 0..65535 bytes).
    public static let OP_PUSHDATA4: OpCode = OpExample() // followed by a 4-byte length of the string to push (allows pushing 0..4294967295 bytes).
    public static let OP_1NEGATE: OpCode = OpExample() // pushes -1 number on the stack
    public static let OP_RESERVED: OpCode = OpExample() // Not assigned. If executed, transaction is invalid.

    // public static let OP_<N> pushes number <N> on the stack
    public static let OP_1: OpCode = OpExample()
    public static let OP_TRUE = OP_1
    public static let OP_2: OpCode = OpExample()
    public static let OP_3: OpCode = OpExample()
    public static let OP_4: OpCode = OpExample()
    public static let OP_5: OpCode = OpExample()
    public static let OP_6: OpCode = OpExample()
    public static let OP_7: OpCode = OpExample()
    public static let OP_8: OpCode = OpExample()
    public static let OP_9: OpCode = OpExample()
    public static let OP_10: OpCode = OpExample()
    public static let OP_11: OpCode = OpExample()
    public static let OP_12: OpCode = OpExample()
    public static let OP_13: OpCode = OpExample()
    public static let OP_14: OpCode = OpExample()
    public static let OP_15: OpCode = OpExample()
    public static let OP_16: OpCode = OpExample()

    // 2. Control flow operators

    public static let OP_NOP: OpCode = OpExample() // Does nothing
    public static let OP_VER: OpCode = OpExample() // Not assigned. If executed, transaction is invalid.

    // BitcoinQT executes all operators from public static let OP_IF to public static let OP_ENDIF even inside "non-executed" branch (to keep track of nesting).
    // Since public static let OP_VERIF and public static let OP_VERNOTIF are not assigned, even inside a non-executed branch they will fall in "default:" switch case
    // and cause the script to fail. Some other ops like public static let OP_VER can be present inside non-executed branch because they'll be skipped.
    public static let OP_IF: OpCode = OpExample() // If the top stack value is not 0, the statements are executed. The top stack value is removed.
    public static let OP_NOTIF: OpCode = OpExample() // If the top stack value is 0, the statements are executed. The top stack value is removed.
    public static let OP_VERIF: OpCode = OpExample() // Not assigned. Script is invalid with that opcode (even if inside non-executed branch).
    public static let OP_VERNOTIF: OpCode = OpExample() // Not assigned. Script is invalid with that opcode (even if inside non-executed branch).
    public static let OP_ELSE: OpCode = OpExample() // Executes code if the previous public static let OP_IF or public static let OP_NOTIF was not executed.
    public static let OP_ENDIF: OpCode = OpExample() // Finishes if/else block

    public static let OP_VERIFY: OpCode = OpExample() // Removes item from the stack if it's not 0x00 or 0x80 (negative zero). Otherwise, marks script as invalid.
    public static let OP_RETURN: OpCode = OpExample() // Marks transaction as invalid.

    // Stack ops
    public static let OP_TOALTSTACK: OpCode = OpExample() // Moves item from the stack to altstack
    public static let OP_FROMALTSTACK: OpCode = OpExample() // Moves item from the altstack to stack
    public static let OP_2DROP: OpCode = OpExample()
    public static let OP_2DUP: OpCode = OpExample()
    public static let OP_3DUP: OpCode = OpExample()
    public static let OP_2OVER: OpCode = OpExample()
    public static let OP_2ROT: OpCode = OpExample()
    public static let OP_2SWAP: OpCode = OpExample()
    public static let OP_IFDUP: OpCode = OpExample()
    public static let OP_DEPTH: OpCode = OpExample()
    public static let OP_DROP: OpCode = OpExample()
    public static let OP_DUP: OpCode = OpExample()
    public static let OP_NIP: OpCode = OpExample()
    public static let OP_OVER: OpCode = OpExample()
    public static let OP_PICK: OpCode = OpExample()
    public static let OP_ROLL: OpCode = OpExample()
    public static let OP_ROT: OpCode = OpExample()
    public static let OP_SWAP: OpCode = OpExample()
    public static let OP_TUCK: OpCode = OpExample()

    // Splice ops
    public static let OP_CAT: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_SUBSTR: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_LEFT: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_RIGHT: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_SIZE: OpCode = OpExample()

    // Bit logic
    public static let OP_INVERT: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_AND: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_OR: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_XOR: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.

    public static let OP_EQUAL: OpCode = OpExample()       // Last two items are removed from the stack and compared. Result (true or false) is pushed to the stack.
    public static let OP_EQUALVERIFY: OpCode = OpExample() // Same as public static let OP_EQUAL, but removes the result from the stack if it's true or marks script as invalid.

    public static let OP_RESERVED1: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_RESERVED2: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.

    // Numeric
    public static let OP_1ADD: OpCode = OpExample() // adds 1 to last item, pops it from stack and pushes result.
    public static let OP_1SUB: OpCode = OpExample() // substracts 1 to last item, pops it from stack and pushes result.
    public static let OP_2MUL: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_2DIV: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_NEGATE: OpCode = OpExample() // negates the number, pops it from stack and pushes result.
    public static let OP_ABS: OpCode = OpExample() // replaces number with its absolute value
    public static let OP_NOT: OpCode = OpExample() // replaces number with True if it's zero, False otherwise.
    public static let OP_0NOTEQUAL: OpCode = OpExample() // replaces number with True if it's not zero, False otherwise.

    public static let OP_ADD: OpCode = OpExample() // (x y -- x+y)
    public static let OP_SUB: OpCode = OpExample() // (x y -- x-y)
    public static let OP_MUL: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_DIV: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_MOD: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_LSHIFT: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_RSHIFT: OpCode = OpExample() // Disabled opcode. If executed, transaction is invalid.

    public static let OP_BOOLAND: OpCode = OpExample()
    public static let OP_BOOLOR: OpCode = OpExample()
    public static let OP_NUMEQUAL: OpCode = OpExample()
    public static let OP_NUMEQUALVERIFY: OpCode = OpExample()
    public static let OP_NUMNOTEQUAL: OpCode = OpExample()
    public static let OP_LESSTHAN: OpCode = OpExample()
    public static let OP_GREATERTHAN: OpCode = OpExample()
    public static let OP_LESSTHANOREQUAL: OpCode = OpExample()
    public static let OP_GREATERTHANOREQUAL: OpCode = OpExample()
    public static let OP_MIN: OpCode = OpExample()
    public static let OP_MAX: OpCode = OpExample()

    public static let OP_WITHIN: OpCode = OpExample()

    // Crypto
    public static let OP_RIPEMD160: OpCode = OpExample()
    public static let OP_SHA1: OpCode = OpExample()
    public static let OP_SHA256: OpCode = OpExample()
    public static let OP_HASH160: OpCode = OpExample()
    public static let OP_HASH256: OpCode = OpExample()
    public static let OP_CODESEPARATOR: OpCode = OpExample() // This opcode is rarely used because it's useless, but we need to support it anyway.
    public static let OP_CHECKSIG: OpCode = OpExample()
    public static let OP_CHECKSIGVERIFY: OpCode = OpExample()
    public static let OP_CHECKMULTISIG: OpCode = OpExample()
    public static let OP_CHECKMULTISIGVERIFY: OpCode = OpExample()

    // Expansion
    public static let OP_NOP1: OpCode = OpExample()
    public static let OP_NOP2: OpCode = OpExample()
    public static let OP_NOP3: OpCode = OpExample()
    public static let OP_NOP4: OpCode = OpExample()
    public static let OP_NOP5: OpCode = OpExample()
    public static let OP_NOP6: OpCode = OpExample()
    public static let OP_NOP7: OpCode = OpExample()
    public static let OP_NOP8: OpCode = OpExample()
    public static let OP_NOP9: OpCode = OpExample()
    public static let OP_NOP10: OpCode = OpExample()

    public static let OP_INVALIDOPCODE: OpCode = OpInvalidOpCode()

    fileprivate static let list: [OpCode] = [
        OP_PUSHDATA1,
        OP_PUSHDATA2,
        OP_PUSHDATA4
    ]

    fileprivate init() {}
}

public struct OpCodeFactory {
    public static func get(with value: UInt8) -> OpCode {
        guard let item = (OpCode.list.first { $0.value == value }) else {
            return OpInvalidOpCode()
        }
        return item
    }

    public static func get(with name: String) -> OpCode {
        guard let item = (OpCode.list.first { $0.name == name }) else {
            return OpInvalidOpCode()
        }
        return item
    }

    // Returns OP_1NEGATE, OP_0 .. OP_16 for ints from -1 to 16.
    // Returns OP_INVALIDOPCODE for other ints.
    public static func opcodeForSmallInteger(smallInteger: Int) -> OpCode {
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
    public static func smallIntegerFromOpcode(opcode: OpCode) -> Int {
        switch opcode {
        case .OP_1NEGATE:
            return -1
        case .OP_0:
            return 0
        case (.OP_1)...(.OP_16):
            return Int(opcode.value - OpCode.OP_1.value - 1)
        default:
            return Int.max
        }
    }
}

extension OpCode: Comparable {
    public static func == (lhs: OpCode, rhs: OpCode) -> Bool {
        return lhs.value == rhs.value
    }

    public static func < (lhs: OpCode, rhs: OpCode) -> Bool {
        return lhs.value < rhs.value
    }
}

public class OpExample: OpCode {
    override public var value: UInt8 { return 0x00 }
    override public var name: String { return "OP_EXAMPLE" }

    override public func isEnabled() -> Bool {
        return true
    }
    override public func execute(_ context: ScriptExecutionContext) throws {
        // do something with context here!
    }
}

public class OpInvalidOpCode: OpCode {
    override public var value: UInt8 { return 0xff }
    override public var name: String { return "OP_INVALIDOPCODE" }

    override public func isEnabled() -> Bool {
        return true
    }
    override public func execute(_ context: ScriptExecutionContext) throws {
        // do something with context here!
    }
}
