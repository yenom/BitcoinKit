//
//  OpCode.swift
//
//  Copyright © 2018 BitcoinCashKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public struct OpCode {
    // 1. Operators pushing data on stack.

    // Push 1 byte 0x00 on the stack
    public static let OP_0: OpCodeProtocol = Op0()
    public static let OP_FALSE = OP_0

    // Any opcode with value < PUSHDATA1 is a length of the string to be pushed on the stack.
    // So opcode 0x01 is followed by 1 byte of data, 0x09 by 9 bytes and so on up to 0x4b (75 bytes)

    // PUSHDATA<N> opcode is followed by N-byte length of the string that follows.
    public static let OP_PUSHDATA1: OpCodeProtocol = OpPushData1() // followed by a 1-byte length of the string to push (allows pushing 0..255 bytes).
    public static let OP_PUSHDATA2: OpCodeProtocol = OpPushData2() // followed by a 2-byte length of the string to push (allows pushing 0..65535 bytes).
    public static let OP_PUSHDATA4: OpCodeProtocol = OpPushData4() // followed by a 4-byte length of the string to push (allows pushing 0..4294967295 bytes).
    public static let OP_1NEGATE: OpCodeProtocol = Op1Negate() // pushes -1 number on the stack
    public static let OP_RESERVED: OpCodeProtocol = OpExample() // Not assigned. If executed, transaction is invalid.

    // public static let OP_<N> pushes number <N> on the stack
    public static let OP_1: OpCodeProtocol = OpN(1)
    public static let OP_TRUE = OP_1
    public static let OP_2: OpCodeProtocol = OpN(2)
    public static let OP_3: OpCodeProtocol = OpN(3)
    public static let OP_4: OpCodeProtocol = OpN(4)
    public static let OP_5: OpCodeProtocol = OpN(5)
    public static let OP_6: OpCodeProtocol = OpN(6)
    public static let OP_7: OpCodeProtocol = OpN(7)
    public static let OP_8: OpCodeProtocol = OpN(8)
    public static let OP_9: OpCodeProtocol = OpN(9)
    public static let OP_10: OpCodeProtocol = OpN(10)
    public static let OP_11: OpCodeProtocol = OpN(11)
    public static let OP_12: OpCodeProtocol = OpN(12)
    public static let OP_13: OpCodeProtocol = OpN(13)
    public static let OP_14: OpCodeProtocol = OpN(14)
    public static let OP_15: OpCodeProtocol = OpN(15)
    public static let OP_16: OpCodeProtocol = OpN(16)

    // 2. Control flow operators

    public static let OP_NOP: OpCodeProtocol = OpExample() // Does nothing
    public static let OP_VER: OpCodeProtocol = OpExample() // Not assigned. If executed, transaction is invalid.

    // BitcoinQT executes all operators from public static let OP_IF to public static let OP_ENDIF even inside "non-executed" branch (to keep track of nesting).
    // Since public static let OP_VERIF and public static let OP_VERNOTIF are not assigned, even inside a non-executed branch they will fall in "default:" switch case
    // and cause the script to fail. Some other ops like public static let OP_VER can be present inside non-executed branch because they'll be skipped.
    public static let OP_IF: OpCodeProtocol = OpExample() // If the top stack value is not 0, the statements are executed. The top stack value is removed.
    public static let OP_NOTIF: OpCodeProtocol = OpExample() // If the top stack value is 0, the statements are executed. The top stack value is removed.
    public static let OP_VERIF: OpCodeProtocol = OpExample() // Not assigned. Script is invalid with that opcode (even if inside non-executed branch).
    public static let OP_VERNOTIF: OpCodeProtocol = OpExample() // Not assigned. Script is invalid with that opcode (even if inside non-executed branch).
    public static let OP_ELSE: OpCodeProtocol = OpExample() // Executes code if the previous public static let OP_IF or public static let OP_NOTIF was not executed.
    public static let OP_ENDIF: OpCodeProtocol = OpExample() // Finishes if/else block

    public static let OP_VERIFY: OpCodeProtocol = OpVerify() // Removes item from the stack if it's not 0x00 or 0x80 (negative zero). Otherwise, marks script as invalid.
    public static let OP_RETURN: OpCodeProtocol = OpExample() // Marks transaction as invalid.

    // Stack ops
    public static let OP_TOALTSTACK: OpCodeProtocol = OpExample() // Moves item from the stack to altstack
    public static let OP_FROMALTSTACK: OpCodeProtocol = OpExample() // Moves item from the altstack to stack
    public static let OP_2DROP: OpCodeProtocol = OpExample()
    public static let OP_2DUP: OpCodeProtocol = OpExample()
    public static let OP_3DUP: OpCodeProtocol = OpExample()
    public static let OP_2OVER: OpCodeProtocol = OpExample()
    public static let OP_2ROT: OpCodeProtocol = OpExample()
    public static let OP_2SWAP: OpCodeProtocol = OpExample()
    public static let OP_IFDUP: OpCodeProtocol = OpExample()
    public static let OP_DEPTH: OpCodeProtocol = OpExample()
    public static let OP_DROP: OpCodeProtocol = OpExample()
    public static let OP_DUP: OpCodeProtocol = OpDuplicate()
    public static let OP_NIP: OpCodeProtocol = OpExample()
    public static let OP_OVER: OpCodeProtocol = OpExample()
    public static let OP_PICK: OpCodeProtocol = OpExample()
    public static let OP_ROLL: OpCodeProtocol = OpExample()
    public static let OP_ROT: OpCodeProtocol = OpExample()
    public static let OP_SWAP: OpCodeProtocol = OpSwap()
    public static let OP_TUCK: OpCodeProtocol = OpExample()

    // Splice ops
    public static let OP_CAT: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_SUBSTR: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_LEFT: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_RIGHT: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_SIZE: OpCodeProtocol = OpExample()

    // Bit logic
    public static let OP_INVERT: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_AND: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_OR: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_XOR: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.

    public static let OP_EQUAL: OpCodeProtocol = OpEqual()       // Last two items are removed from the stack and compared. Result (true or false) is pushed to the stack.
    public static let OP_EQUALVERIFY: OpCodeProtocol = OpEqualVerify() // Same as public static let OP_EQUAL, but removes the result from the stack if it's true or marks script as invalid.

    public static let OP_RESERVED1: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_RESERVED2: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.

    // Numeric
    public static let OP_1ADD: OpCodeProtocol = OpExample() // adds 1 to last item, pops it from stack and pushes result.
    public static let OP_1SUB: OpCodeProtocol = OpExample() // substracts 1 to last item, pops it from stack and pushes result.
    public static let OP_2MUL: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_2DIV: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_NEGATE: OpCodeProtocol = OpExample() // negates the number, pops it from stack and pushes result.
    public static let OP_ABS: OpCodeProtocol = OpExample() // replaces number with its absolute value
    public static let OP_NOT: OpCodeProtocol = OpExample() // replaces number with True if it's zero, False otherwise.
    public static let OP_0NOTEQUAL: OpCodeProtocol = OpExample() // replaces number with True if it's not zero, False otherwise.

    public static let OP_ADD: OpCodeProtocol = OpExample() // (x y -- x+y)
    public static let OP_SUB: OpCodeProtocol = OpExample() // (x y -- x-y)
    public static let OP_MUL: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_DIV: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_MOD: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_LSHIFT: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.
    public static let OP_RSHIFT: OpCodeProtocol = OpExample() // Disabled opcode. If executed, transaction is invalid.

    public static let OP_BOOLAND: OpCodeProtocol = OpExample()
    public static let OP_BOOLOR: OpCodeProtocol = OpExample()
    public static let OP_NUMEQUAL: OpCodeProtocol = OpExample()
    public static let OP_NUMEQUALVERIFY: OpCodeProtocol = OpExample()
    public static let OP_NUMNOTEQUAL: OpCodeProtocol = OpExample()
    public static let OP_LESSTHAN: OpCodeProtocol = OpExample()
    public static let OP_GREATERTHAN: OpCodeProtocol = OpExample()
    public static let OP_LESSTHANOREQUAL: OpCodeProtocol = OpExample()
    public static let OP_GREATERTHANOREQUAL: OpCodeProtocol = OpExample()
    public static let OP_MIN: OpCodeProtocol = OpExample()
    public static let OP_MAX: OpCodeProtocol = OpExample()

    public static let OP_WITHIN: OpCodeProtocol = OpExample()

    // Crypto
    public static let OP_RIPEMD160: OpCodeProtocol = OpExample()
    public static let OP_SHA1: OpCodeProtocol = OpExample()
    public static let OP_SHA256: OpCodeProtocol = OpExample()
    public static let OP_HASH160: OpCodeProtocol = OpHash160()
    public static let OP_HASH256: OpCodeProtocol = OpExample()
    public static let OP_CODESEPARATOR: OpCodeProtocol = OpExample() // This opcode is rarely used because it's useless, but we need to support it anyway.
    public static let OP_CHECKSIG: OpCodeProtocol = OpCheckSig()
    public static let OP_CHECKSIGVERIFY: OpCodeProtocol = OpCheckSigVerify()
    public static let OP_CHECKMULTISIG: OpCodeProtocol = OpCheckMultiSig()
    public static let OP_CHECKMULTISIGVERIFY: OpCodeProtocol = OpCheckMultiSigVerify()

    // Expansion
    public static let OP_NOP1: OpCodeProtocol = OpExample()
    public static let OP_NOP2: OpCodeProtocol = OpExample()
    public static let OP_NOP3: OpCodeProtocol = OpExample()
    public static let OP_NOP4: OpCodeProtocol = OpExample()
    public static let OP_NOP5: OpCodeProtocol = OpExample()
    public static let OP_NOP6: OpCodeProtocol = OpExample()
    public static let OP_NOP7: OpCodeProtocol = OpExample()
    public static let OP_NOP8: OpCodeProtocol = OpExample()
    public static let OP_NOP9: OpCodeProtocol = OpExample()
    public static let OP_NOP10: OpCodeProtocol = OpExample()

    public static let OP_INVALIDOPCODE: OpCodeProtocol = OpInvalidOpCode()

    internal static let list: [OpCodeProtocol] = [
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
