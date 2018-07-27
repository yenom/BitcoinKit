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

    public func isEnabled() -> Bool { return true }
    public func execute(_ context: ScriptExecutionContext) throws {
        context.opCount += 1
        guard context.opCount <= BTC_MAX_OPS_PER_SCRIPT else {
            throw ScriptMachineError.error("Exceeded the allowed number of operations per script.")
        }
    }

    // 1. Operators pushing data on stack.

    // Push 1 byte 0x00 on the stack
    public static let OP_0: OpCode = Op0()
    public static let OP_FALSE = OP_0

    // Any opcode with value < PUSHDATA1 is a length of the string to be pushed on the stack.
    // So opcode 0x01 is followed by 1 byte of data, 0x09 by 9 bytes and so on up to 0x4b (75 bytes)

    // PUSHDATA<N> opcode is followed by N-byte length of the string that follows.
    public static let OP_PUSHDATA1: OpCode = OpPushData1() // followed by a 1-byte length of the string to push (allows pushing 0..255 bytes).
    public static let OP_PUSHDATA2: OpCode = OpPushData2() // followed by a 2-byte length of the string to push (allows pushing 0..65535 bytes).
    public static let OP_PUSHDATA4: OpCode = OpPushData4() // followed by a 4-byte length of the string to push (allows pushing 0..4294967295 bytes).
    public static let OP_1NEGATE: OpCode = OpExample() // pushes -1 number on the stack
    public static let OP_RESERVED: OpCode = OpExample() // Not assigned. If executed, transaction is invalid.

    // public static let OP_<N> pushes number <N> on the stack
    public static let OP_1: OpCode = OpN(1)
    public static let OP_TRUE = OP_1
    public static let OP_2: OpCode = OpN(2)
    public static let OP_3: OpCode = OpN(3)
    public static let OP_4: OpCode = OpN(4)
    public static let OP_5: OpCode = OpN(5)
    public static let OP_6: OpCode = OpN(6)
    public static let OP_7: OpCode = OpN(7)
    public static let OP_8: OpCode = OpN(8)
    public static let OP_9: OpCode = OpN(9)
    public static let OP_10: OpCode = OpN(10)
    public static let OP_11: OpCode = OpN(11)
    public static let OP_12: OpCode = OpN(12)
    public static let OP_13: OpCode = OpN(13)
    public static let OP_14: OpCode = OpN(14)
    public static let OP_15: OpCode = OpN(15)
    public static let OP_16: OpCode = OpN(16)

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

    public static let OP_VERIFY: OpCode = OpVerify() // Removes item from the stack if it's not 0x00 or 0x80 (negative zero). Otherwise, marks script as invalid.
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
    public static let OP_DUP: OpCode = OpDuplicate()
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

    public static let OP_EQUAL: OpCode = OpEqual()       // Last two items are removed from the stack and compared. Result (true or false) is pushed to the stack.
    public static let OP_EQUALVERIFY: OpCode = OpEqualVerify() // Same as public static let OP_EQUAL, but removes the result from the stack if it's true or marks script as invalid.

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
    public static let OP_HASH160: OpCode = OpHash160()
    public static let OP_HASH256: OpCode = OpExample()
    public static let OP_CODESEPARATOR: OpCode = OpExample() // This opcode is rarely used because it's useless, but we need to support it anyway.
    public static let OP_CHECKSIG: OpCode = OpCheckSig()
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

    internal static let list: [OpCode] = [
        OP_0,
        OP_FALSE,
        OP_PUSHDATA1,
        OP_PUSHDATA2,
        OP_PUSHDATA4,
        OP_1NEGATE,
        OP_RESERVED,
        OP_1,
        OP_TRUE,
        OP_2,
        OP_3,
        OP_4,
        OP_5,
        OP_6,
        OP_7,
        OP_8,
        OP_9,
        OP_10,
        OP_11,
        OP_12,
        OP_13,
        OP_14,
        OP_15,
        OP_16,
        OP_NOP,
        OP_VER,
        OP_IF,
        OP_NOTIF,
        OP_VERIF,
        OP_VERNOTIF,
        OP_ELSE,
        OP_ENDIF,
        OP_VERIFY,
        OP_RETURN,
        OP_TOALTSTACK,
        OP_FROMALTSTACK,
        OP_2DROP,
        OP_2DUP,
        OP_3DUP,
        OP_2OVER,
        OP_2ROT,
        OP_2SWAP,
        OP_IFDUP,
        OP_DEPTH,
        OP_DROP,
        OP_DUP,
        OP_NIP,
        OP_OVER,
        OP_PICK,
        OP_ROLL,
        OP_ROT,
        OP_SWAP,
        OP_TUCK,
        OP_CAT,
        OP_SUBSTR,
        OP_LEFT,
        OP_RIGHT,
        OP_SIZE,
        OP_INVERT,
        OP_AND,
        OP_OR,
        OP_XOR,
        OP_EQUAL,
        OP_EQUALVERIFY,
        OP_RESERVED1,
        OP_RESERVED2,
        OP_1ADD,
        OP_1SUB,
        OP_2MUL,
        OP_2DIV,
        OP_NEGATE,
        OP_ABS,
        OP_NOT,
        OP_0NOTEQUAL,
        OP_ADD,
        OP_SUB,
        OP_MUL,
        OP_DIV,
        OP_MOD,
        OP_LSHIFT,
        OP_RSHIFT,
        OP_BOOLAND,
        OP_BOOLOR,
        OP_NUMEQUAL,
        OP_NUMEQUALVERIFY,
        OP_NUMNOTEQUAL,
        OP_LESSTHAN,
        OP_GREATERTHAN,
        OP_LESSTHANOREQUAL,
        OP_GREATERTHANOREQUAL,
        OP_MIN,
        OP_MAX,
        OP_WITHIN,
        OP_RIPEMD160,
        OP_SHA1,
        OP_SHA256,
        OP_HASH160,
        OP_HASH256,
        OP_CODESEPARATOR,
        OP_CHECKSIG,
        OP_CHECKSIGVERIFY,
        OP_CHECKMULTISIG,
        OP_CHECKMULTISIGVERIFY,
        OP_NOP1,
        OP_NOP2,
        OP_NOP3,
        OP_NOP4,
        OP_NOP5,
        OP_NOP6,
        OP_NOP7,
        OP_NOP8,
        OP_NOP9,
        OP_NOP10,
        OP_INVALIDOPCODE
    ]

    internal init() {}
}

extension OpCode: Comparable {
    public static func == (lhs: OpCode, rhs: OpCode) -> Bool {
        return lhs.value == rhs.value
    }

    public static func < (lhs: OpCode, rhs: OpCode) -> Bool {
        return lhs.value < rhs.value
    }
}

// TODO: Remove this when all opcodes are implemented
public class OpExample: OpCode {
    override public var value: UInt8 { return 0x00 }
    override public var name: String { return "OP_EXAMPLE" }

    override public func execute(_ context: ScriptExecutionContext) throws {
        try super.execute(context)
        // do something with context here!
        fatalError("You should implement this!")
    }
}
