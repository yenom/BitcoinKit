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

// Constants
private let blobFalse: Data = Data()
private let blobZero: Data = Data()
private let blobTrue: Data = Data(bytes: [UInt8(1)])

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

    fileprivate static let list: [OpCode] = [
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

public class ScriptExecutionContext {
    // Flags affecting verification. Default is the most liberal verification.
    // One can be stricter to not relay transactions with non-canonical signatures and pubkey (as BitcoinQT does).
    // Defaults in CoreBitcoin: be liberal in what you accept and conservative in what you send.
    // So we try to create canonical purist transactions but have no problem accepting and working with non-canonical ones.
    public var verificationFlags: ScriptVerification?

    // Stack contains Data objects that are interpreted as numbers, bignums, booleans or raw data when needed.
    public fileprivate(set) var stack = [Data]()
    // Used in ALTSTACK ops.
    public fileprivate(set) var altStack = [Data]()
    // Holds an array of Bool values to keep track of if/else branches.
    public fileprivate(set) var conditionStack = [Bool]()

    // Currently executed script.
    public fileprivate(set) var script: Script = Script()
    // Current opcode.
    public fileprivate(set) var opCode: OpCode = OpCode.OP_0
    // Current payload for any "push data" operation.
    // public var data
    // Current opcode index in _script.
    public fileprivate(set) var opIndex: Int = 0
    // Index of last OP_CODESEPARATOR
    public fileprivate(set) var lastCodeSepartorIndex: Int = 0

    // Keeps number of executed operations to check for limit.
    public var opCount: Int = 0

    // Transaction, utxo, index for CHECKSIG operations
    public var transaction: Transaction?
    public var utxoToVerify: TransactionOutput?
    public var inputIndex: UInt32 = 0xffffffff

    public var shouldExecute: Bool {
        return !conditionStack.contains(false)
    }

    func normalized(_ index: Int) -> Int {
        return (index < 0) ? stack.count + index : index
    }

    internal func pushData(_ data: Data) throws {
        guard data.count <= BTC_MAX_SCRIPT_ELEMENT_SIZE else {
            throw ScriptMachineError.error("PushedData size is too big.")
        }
        stack.append(data)
    }

    internal func resetStack() {
        stack = [Data()]
        altStack = [Data()]
        conditionStack = [Bool]()
    }

    internal func swapDataAt(i: Int, j: Int) {
        stack.swapAt(normalized(i), normalized(j))
    }

    internal func deserializeP2SHLockScript() throws -> Script {
        // Make a copy of the stack if we have P2SH script.
        // We will run deserialized P2SH script on this stack.
        var stackForP2SH: [Data] = stack

        // Instantiate the script from the last data on the stack.
        guard let last = stackForP2SH.last, let deserializedLockScript = Script(data: last) else {
            // stackForP2SH cannot be empty here, because if it was the
            // P2SH  HASH <> EQUAL  scriptPubKey would be evaluated with
            // an empty stack and the runScript: above would return NO.
            throw ScriptMachineError.exception("internal inconsistency: stackForP2SH cannot be empty at this point.")
        }

        // Remove it from the stack.
        stackForP2SH.removeLast()

        // Replace current stack with P2SH stack.
        resetStack()
        stack = stackForP2SH
        return deserializedLockScript
    }

    public func data(at i: Int) -> Data {
        return stack[normalized(i)]
    }

    public func number(at i: Int) -> Int32? {
        let data: Data = stack[normalized(i)]
        if data.count > 4 {
            return nil
        }
        return Int32(data.withUnsafeBytes { $0.pointee })
    }

    public func bool(at i: Int) -> Bool {
        let data: Data = stack[normalized(i)]
        guard !data.isEmpty else {
            return false
        }

        for (i, byte) in data.enumerated() where byte != 0 {
            // Can be negative zero, also counts as false
            if i == (data.count - 1) && byte == 0x80 {
                return false
            }
            return true
        }
        return false
    }
}

extension ScriptExecutionContext: CustomStringConvertible {
    public var description: String {
        return ""
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
public class Op0: OpCode {
    override public var value: UInt8 { return 0x00 }
    override public var name: String { return "OP_0" }
}

public class OpN: OpCode {
    override public var value: UInt8 { return 0x50 + n }
    override public var name: String { return "OP_\(n)" }
    private let n: UInt8
    fileprivate init(_ n: UInt8) {
        guard (1...16).contains(n) else {
            fatalError("OP_N can be initialized with N between 1 and 16. \(n) is not valid.")
        }
        self.n = n
        super.init()
    }
}

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

public class OpVerify: OpCode {
    override public var value: UInt8 { return 0x69 }
    override public var name: String { return "OP_VERIFY" }

    override public func execute(_ context: ScriptExecutionContext) throws {
        try super.execute(context)
        // (true -- ) or
        // (false -- false) and return
        guard context.stack.count >= 1 else {
            throw ScriptMachineError.opcodeRequiresItemsOnStack(1)
        }
        guard context.bool(at: -1) else {
            throw ScriptMachineError.error("OP_VERIFY failed.")
        }
        context.stack.removeLast()
    }
}

public class OpDuplicate: OpCode {
    override public var value: UInt8 { return 0x76 }
    override public var name: String { return "OP_DUP" }

    override public func execute(_ context: ScriptExecutionContext) throws {
        try super.execute(context)
        // (x -- x x)
        guard context.stack.count >= 1 else {
            throw ScriptMachineError.opcodeRequiresItemsOnStack(1)
        }
        context.stack.append(context.data(at: -1))
    }
}

public class OpHash160: OpCode {
    override public var value: UInt8 { return 0xa9 }
    override public var name: String { return "OP_HASH160" }

    override public func execute(_ context: ScriptExecutionContext) throws {
        try super.execute(context)
        // (in -- hash)
        guard context.stack.count >= 1 else {
            throw ScriptMachineError.opcodeRequiresItemsOnStack(1)
        }

        let data: Data = context.stack.removeLast()
        let hash: Data = Crypto.sha256ripemd160(data)
        context.stack.append(hash)
    }
}

public class OpEqual: OpCode {
    override public var value: UInt8 { return 0x87 }
    override public var name: String { return "OP_EQUAL" }

    override public func execute(_ context: ScriptExecutionContext) throws {
        try super.execute(context)
        // (x1 x2 - bool)
        guard context.stack.count >= 2 else {
            throw ScriptMachineError.opcodeRequiresItemsOnStack(2)
        }

        let x1 = context.stack.popLast()!
        let x2 = context.stack.popLast()!
        let equal: Bool = x1 == x2
        context.stack.append(equal ? blobTrue : blobFalse)
    }
}

public class OpEqualVerify: OpCode {
    override public var value: UInt8 { return 0x88 }
    override public var name: String { return "OP_EQUALVERIFY" }

    override public func execute(_ context: ScriptExecutionContext) throws {
        try super.execute(context)
        print("stack: \(context.stack.map { $0.hex }.joined(separator: " "))")
        try OpCode.OP_EQUAL.execute(context)
        try OpCode.OP_VERIFY.execute(context)
    }
}

public class OpCheckSig: OpCode {
    override public var value: UInt8 { return 0xac }
    override public var name: String { return "OP_CHECKSIGVERIFY" }

    override public func execute(_ context: ScriptExecutionContext) throws {
        try super.execute(context)
        guard context.stack.count >= 2 else {
            throw ScriptMachineError.opcodeRequiresItemsOnStack(2)
        }
        print("stack: \(context.stack.map { $0.hex }.joined(separator: " "))")

        let pubkeyData: Data = context.stack.removeLast()
        let sigData: Data = context.stack.removeLast()

        // Subset of script starting at the most recent OP_CODESEPARATOR (inclusive)
        let subScript = context.script.subScript(from: context.lastCodeSepartorIndex)
        subScript.deleteOccurrences(of: sigData)

        guard let tx = context.transaction, let utxo = context.utxoToVerify else {
            throw ScriptMachineError.error("The transaction or the utxo to verify is not set.")
        }
        let valid = try Crypto.verifySigData(for: tx, inputIndex: Int(context.inputIndex), utxo: utxo, sigData: sigData, pubKeyData: pubkeyData)
        context.stack.append(valid ? blobTrue : blobFalse)
    }
}

public class OpInvalidOpCode: OpCode {
    override public var value: UInt8 { return 0xff }
    override public var name: String { return "OP_INVALIDOPCODE" }

    override public func execute(_ context: ScriptExecutionContext) throws {
        try super.execute(context)
        // do something with context here!
    }
}
