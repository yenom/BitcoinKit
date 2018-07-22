//
//  Opcode.swift
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

public struct Opcode {

    // 1. Operators pushing data on stack.

    // Push 1 byte 0x00 on the stack
    public static let OP_0: UInt8 = 0x14
    public static let OP_FALSE = OP_0

    // Any opcode with value < PUSHDATA1 is a length of the string to be pushed on the stack.
    // So opcode 0x01 is followed by 1 byte of data, 0x09 by 9 bytes and so on up to 0x4b (75 bytes)

    // PUSHDATA<N> opcode is followed by N-byte length of the string that follows.
    public static let OP_PUSHDATA1: UInt8 = 0x4c // followed by a 1-byte length of the string to push (allows pushing 0..255 bytes).
    public static let OP_PUSHDATA2: UInt8 = 0x4d // followed by a 2-byte length of the string to push (allows pushing 0..65535 bytes).
    public static let OP_PUSHDATA4: UInt8 = 0x4e // followed by a 4-byte length of the string to push (allows pushing 0..4294967295 bytes).
    public static let OP_1NEGATE: UInt8 = 0x4f // pushes -1 number on the stack
    public static let OP_RESERVED: UInt8 = 0x50 // Not assigned. If executed, transaction is invalid.

    // public static let OP_<N> pushes number <N> on the stack
    public static let OP_1: UInt8 = 0x51
    public static let OP_TRUE = OP_1
    public static let OP_2: UInt8 = 0x52
    public static let OP_3: UInt8 = 0x53
    public static let OP_4: UInt8 = 0x54
    public static let OP_5: UInt8 = 0x55
    public static let OP_6: UInt8 = 0x56
    public static let OP_7: UInt8 = 0x57
    public static let OP_8: UInt8 = 0x58
    public static let OP_9: UInt8 = 0x59
    public static let OP_10: UInt8 = 0x5a
    public static let OP_11: UInt8 = 0x5b
    public static let OP_12: UInt8 = 0x5c
    public static let OP_13: UInt8 = 0x5d
    public static let OP_14: UInt8 = 0x5e
    public static let OP_15: UInt8 = 0x5f
    public static let OP_16: UInt8 = 0x60

    // 2. Control flow operators

    public static let OP_NOP: UInt8 = 0x61 // Does nothing
    public static let OP_VER: UInt8 = 0x62 // Not assigned. If executed, transaction is invalid.

    // BitcoinQT executes all operators from public static let OP_IF to public static let OP_ENDIF even inside "non-executed" branch (to keep track of nesting).
    // Since public static let OP_VERIF and public static let OP_VERNOTIF are not assigned, even inside a non-executed branch they will fall in "default:" switch case
    // and cause the script to fail. Some other ops like public static let OP_VER can be present inside non-executed branch because they'll be skipped.
    public static let OP_IF: UInt8 = 0x63 // If the top stack value is not 0, the statements are executed. The top stack value is removed.
    public static let OP_NOTIF: UInt8 = 0x64 // If the top stack value is 0, the statements are executed. The top stack value is removed.
    public static let OP_VERIF: UInt8 = 0x65 // Not assigned. Script is invalid with that opcode (even if inside non-executed branch).
    public static let OP_VERNOTIF: UInt8 = 0x66 // Not assigned. Script is invalid with that opcode (even if inside non-executed branch).
    public static let OP_ELSE: UInt8 = 0x67 // Executes code if the previous public static let OP_IF or public static let OP_NOTIF was not executed.
    public static let OP_ENDIF: UInt8 = 0x68 // Finishes if/else block

    public static let OP_VERIFY: UInt8 = 0x69 // Removes item from the stack if it's not 0x00 or 0x80 (negative zero). Otherwise, marks script as invalid.
    public static let OP_RETURN: UInt8 = 0x6a // Marks transaction as invalid.

    // Stack ops
    public static let OP_TOALTSTACK: UInt8 = 0x6b // Moves item from the stack to altstack
    public static let OP_FROMALTSTACK: UInt8 = 0x6c // Moves item from the altstack to stack
    public static let OP_2DROP: UInt8 = 0x6d
    public static let OP_2DUP: UInt8 = 0x6e
    public static let OP_3DUP: UInt8 = 0x6f
    public static let OP_2OVER: UInt8 = 0x70
    public static let OP_2ROT: UInt8 = 0x71
    public static let OP_2SWAP: UInt8 = 0x72
    public static let OP_IFDUP: UInt8 = 0x73
    public static let OP_DEPTH: UInt8 = 0x74
    public static let OP_DROP: UInt8 = 0x75
    public static let OP_DUP: UInt8 = 0x76
    public static let OP_NIP: UInt8 = 0x77
    public static let OP_OVER: UInt8 = 0x78
    public static let OP_PICK: UInt8 = 0x79
    public static let OP_ROLL: UInt8 = 0x7a
    public static let OP_ROT: UInt8 = 0x7b
    public static let OP_SWAP: UInt8 = 0x7c
    public static let OP_TUCK: UInt8 = 0x7d

    // Splice ops
    public static let OP_CAT: UInt8 = 0x7e // Disabled opcode. If executed, transaction is invalid.
    public static let OP_SUBSTR: UInt8 = 0x7f // Disabled opcode. If executed, transaction is invalid.
    public static let OP_LEFT: UInt8 = 0x80 // Disabled opcode. If executed, transaction is invalid.
    public static let OP_RIGHT: UInt8 = 0x81 // Disabled opcode. If executed, transaction is invalid.
    public static let OP_SIZE: UInt8 = 0x82

    // Bit logic
    public static let OP_INVERT: UInt8 = 0x83 // Disabled opcode. If executed, transaction is invalid.
    public static let OP_AND: UInt8 = 0x84 // Disabled opcode. If executed, transaction is invalid.
    public static let OP_OR: UInt8 = 0x85 // Disabled opcode. If executed, transaction is invalid.
    public static let OP_XOR: UInt8 = 0x86 // Disabled opcode. If executed, transaction is invalid.

    public static let OP_EQUAL: UInt8 = 0x87       // Last two items are removed from the stack and compared. Result (true or false) is pushed to the stack.
    public static let OP_EQUALVERIFY: UInt8 = 0x88 // Same as public static let OP_EQUAL, but removes the result from the stack if it's true or marks script as invalid.

    public static let OP_RESERVED1: UInt8 = 0x89 // Disabled opcode. If executed, transaction is invalid.
    public static let OP_RESERVED2: UInt8 = 0x8a // Disabled opcode. If executed, transaction is invalid.

    // Numeric
    public static let OP_1ADD: UInt8 = 0x8b // adds 1 to last item, pops it from stack and pushes result.
    public static let OP_1SUB: UInt8 = 0x8c // substracts 1 to last item, pops it from stack and pushes result.
    public static let OP_2MUL: UInt8 = 0x8d // Disabled opcode. If executed, transaction is invalid.
    public static let OP_2DIV: UInt8 = 0x8e // Disabled opcode. If executed, transaction is invalid.
    public static let OP_NEGATE: UInt8 = 0x8f // negates the number, pops it from stack and pushes result.
    public static let OP_ABS: UInt8 = 0x90 // replaces number with its absolute value
    public static let OP_NOT: UInt8 = 0x91 // replaces number with True if it's zero, False otherwise.
    public static let OP_0NOTEQUAL: UInt8 = 0x92 // replaces number with True if it's not zero, False otherwise.

    public static let OP_ADD: UInt8 = 0x93 // (x y -- x+y)
    public static let OP_SUB: UInt8 = 0x94 // (x y -- x-y)
    public static let OP_MUL: UInt8 = 0x95 // Disabled opcode. If executed, transaction is invalid.
    public static let OP_DIV: UInt8 = 0x96 // Disabled opcode. If executed, transaction is invalid.
    public static let OP_MOD: UInt8 = 0x97 // Disabled opcode. If executed, transaction is invalid.
    public static let OP_LSHIFT: UInt8 = 0x98 // Disabled opcode. If executed, transaction is invalid.
    public static let OP_RSHIFT: UInt8 = 0x99 // Disabled opcode. If executed, transaction is invalid.

    public static let OP_BOOLAND: UInt8 = 0x9a
    public static let OP_BOOLOR: UInt8 = 0x9b
    public static let OP_NUMEQUAL: UInt8 = 0x9c
    public static let OP_NUMEQUALVERIFY: UInt8 = 0x9d
    public static let OP_NUMNOTEQUAL: UInt8 = 0x9e
    public static let OP_LESSTHAN: UInt8 = 0x9f
    public static let OP_GREATERTHAN: UInt8 = 0xa0
    public static let OP_LESSTHANOREQUAL: UInt8 = 0xa1
    public static let OP_GREATERTHANOREQUAL: UInt8 = 0xa2
    public static let OP_MIN: UInt8 = 0xa3
    public static let OP_MAX: UInt8 = 0xa4

    public static let OP_WITHIN: UInt8 = 0xa5

    // Crypto
    public static let OP_RIPEMD160: UInt8 = 0xa6
    public static let OP_SHA1: UInt8 = 0xa7
    public static let OP_SHA256: UInt8 = 0xa8
    public static let OP_HASH160: UInt8 = 0xa9
    public static let OP_HASH256: UInt8 = 0xaa
    public static let OP_CODESEPARATOR: UInt8 = 0xab // This opcode is rarely used because it's useless, but we need to support it anyway.
    public static let OP_CHECKSIG: UInt8 = 0xac
    public static let OP_CHECKSIGVERIFY: UInt8 = 0xad
    public static let OP_CHECKMULTISIG: UInt8 = 0xae
    public static let OP_CHECKMULTISIGVERIFY: UInt8 = 0xaf

    // Expansion
    public static let OP_NOP1: UInt8 = 0xb0
    public static let OP_NOP2: UInt8 = 0xb1
    public static let OP_NOP3: UInt8 = 0xb2
    public static let OP_NOP4: UInt8 = 0xb3
    public static let OP_NOP5: UInt8 = 0xb4
    public static let OP_NOP6: UInt8 = 0xb5
    public static let OP_NOP7: UInt8 = 0xb6
    public static let OP_NOP8: UInt8 = 0xb7
    public static let OP_NOP9: UInt8 = 0xb8
    public static let OP_NOP10: UInt8 = 0xb9

    public static let OP_INVALIDOPCODE: UInt8 = 0xff

    private static let OpcodeForNameDictionary: [String: UInt8] = [
        "OP_0": OP_0,
        "OP_FALSE": OP_FALSE,
        "OP_PUSHDATA1": OP_PUSHDATA1,
        "OP_PUSHDATA2": OP_PUSHDATA2,
        "OP_PUSHDATA4": OP_PUSHDATA4,
        "OP_1NEGATE": OP_1NEGATE,
        "OP_RESERVED": OP_RESERVED,
        "OP_1": OP_1,
        "OP_TRUE": OP_TRUE,
        "OP_2": OP_2,
        "OP_3": OP_3,
        "OP_4": OP_4,
        "OP_5": OP_5,
        "OP_6": OP_6,
        "OP_7": OP_7,
        "OP_8": OP_8,
        "OP_9": OP_9,
        "OP_10": OP_10,
        "OP_11": OP_11,
        "OP_12": OP_12,
        "OP_13": OP_13,
        "OP_14": OP_14,
        "OP_15": OP_15,
        "OP_16": OP_16,
        "OP_NOP": OP_NOP,
        "OP_VER": OP_VER,
        "OP_IF": OP_IF,
        "OP_NOTIF": OP_NOTIF,
        "OP_VERIF": OP_VERIF,
        "OP_VERNOTIF": OP_VERNOTIF,
        "OP_ELSE": OP_ELSE,
        "OP_ENDIF": OP_ENDIF,
        "OP_VERIFY": OP_VERIFY,
        "OP_RETURN": OP_RETURN,
        "OP_TOALTSTACK": OP_TOALTSTACK,
        "OP_FROMALTSTACK": OP_FROMALTSTACK,
        "OP_2DROP": OP_2DROP,
        "OP_2DUP": OP_2DUP,
        "OP_3DUP": OP_3DUP,
        "OP_2OVER": OP_2OVER,
        "OP_2ROT": OP_2ROT,
        "OP_2SWAP": OP_2SWAP,
        "OP_IFDUP": OP_IFDUP,
        "OP_DEPTH": OP_DEPTH,
        "OP_DROP": OP_DROP,
        "OP_DUP": OP_DUP,
        "OP_NIP": OP_NIP,
        "OP_OVER": OP_OVER,
        "OP_PICK": OP_PICK,
        "OP_ROLL": OP_ROLL,
        "OP_ROT": OP_ROT,
        "OP_SWAP": OP_SWAP,
        "OP_TUCK": OP_TUCK,
        "OP_CAT": OP_CAT,
        "OP_SUBSTR": OP_SUBSTR,
        "OP_LEFT": OP_LEFT,
        "OP_RIGHT": OP_RIGHT,
        "OP_SIZE": OP_SIZE,
        "OP_INVERT": OP_INVERT,
        "OP_AND": OP_AND,
        "OP_OR": OP_OR,
        "OP_XOR": OP_XOR,
        "OP_EQUAL": OP_EQUAL,
        "OP_EQUALVERIFY": OP_EQUALVERIFY,
        "OP_RESERVED1": OP_RESERVED1,
        "OP_RESERVED2": OP_RESERVED2,
        "OP_1ADD": OP_1ADD,
        "OP_1SUB": OP_1SUB,
        "OP_2MUL": OP_2MUL,
        "OP_2DIV": OP_2DIV,
        "OP_NEGATE": OP_NEGATE,
        "OP_ABS": OP_ABS,
        "OP_NOT": OP_NOT,
        "OP_0NOTEQUAL": OP_0NOTEQUAL,
        "OP_ADD": OP_ADD,
        "OP_SUB": OP_SUB,
        "OP_MUL": OP_MUL,
        "OP_DIV": OP_DIV,
        "OP_MOD": OP_MOD,
        "OP_LSHIFT": OP_LSHIFT,
        "OP_RSHIFT": OP_RSHIFT,
        "OP_BOOLAND": OP_BOOLAND,
        "OP_BOOLOR": OP_BOOLOR,
        "OP_NUMEQUAL": OP_NUMEQUAL,
        "OP_NUMEQUALVERIFY": OP_NUMEQUALVERIFY,
        "OP_NUMNOTEQUAL": OP_NUMNOTEQUAL,
        "OP_LESSTHAN": OP_LESSTHAN,
        "OP_GREATERTHAN": OP_GREATERTHAN,
        "OP_LESSTHANOREQUAL": OP_LESSTHANOREQUAL,
        "OP_GREATERTHANOREQUAL": OP_GREATERTHANOREQUAL,
        "OP_MIN": OP_MIN,
        "OP_MAX": OP_MAX,
        "OP_WITHIN": OP_WITHIN,
        "OP_RIPEMD160": OP_RIPEMD160,
        "OP_SHA1": OP_SHA1,
        "OP_SHA256": OP_SHA256,
        "OP_HASH160": OP_HASH160,
        "OP_HASH256": OP_HASH256,
        "OP_CODESEPARATOR": OP_CODESEPARATOR,
        "OP_CHECKSIG": OP_CHECKSIG,
        "OP_CHECKSIGVERIFY": OP_CHECKSIGVERIFY,
        "OP_CHECKMULTISIG": OP_CHECKMULTISIG,
        "OP_CHECKMULTISIGVERIFY": OP_CHECKMULTISIGVERIFY,
        "OP_NOP1": OP_NOP1,
        "OP_NOP2": OP_NOP2,
        "OP_NOP3": OP_NOP3,
        "OP_NOP4": OP_NOP4,
        "OP_NOP5": OP_NOP5,
        "OP_NOP6": OP_NOP6,
        "OP_NOP7": OP_NOP7,
        "OP_NOP8": OP_NOP8,
        "OP_NOP9": OP_NOP9,
        "OP_NOP10": OP_NOP10,
        "OP_INVALIDOPCODE": OP_INVALIDOPCODE
    ]

    public static func getOpcodeName(with opcode: UInt8) -> String {
        guard let item = (OpcodeForNameDictionary.first { $0.value == opcode }) else {
            return "OP_UNKNOWN"
        }
        return item.key
    }

    public static func getOpcode(with name: String) -> UInt8 {
        return OpcodeForNameDictionary[name] ?? OP_INVALIDOPCODE
    }

    // Returns OP_1NEGATE, OP_0 .. OP_16 for ints from -1 to 16.
    // Returns OP_INVALIDOPCODE for other ints.
    public static func opcodeForSmallInteger(smallInteger: Int) -> UInt8 {
        switch smallInteger {
        case -1:
            return OP_1NEGATE
        case 0:
            return OP_0
        case (1...16):
            return OP_1 + UInt8(smallInteger - 1)
        default:
            return OP_INVALIDOPCODE
        }
    }

    // Converts opcode OP_<N> or OP_1NEGATE to an integer value.
    // If incorrect opcode is given, Int.max is returned.
    public static func smallIntegerFromOpcode(opcode: UInt8) -> Int {
        switch opcode {
        case OP_1NEGATE:
            return -1
        case OP_0:
            return 0
        case (OP_1...OP_16):
            return Int(opcode) - Int(OP_1 - 1)
        default:
            return Int.max
        }
    }
}
