//
//  ScriptExecutionContext.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public class ScriptExecutionContext {
    // Flags affecting verification. Default is the most liberal verification.
    // One can be stricter to not relay transactions with non-canonical signatures and pubkey (as BitcoinQT does).
    // Defaults in CoreBitcoin: be liberal in what you accept and conservative in what you send.
    // So we try to create canonical purist transactions but have no problem accepting and working with non-canonical ones.
    public var verificationFlags: ScriptVerification?

    // Stack contains Data objects that are interpreted as numbers, bignums, booleans or raw data when needed.
    public internal(set) var stack = [Data]()
    // Used in ALTSTACK ops.
    public internal(set) var altStack = [Data]()
    // Holds an array of Bool values to keep track of if/else branches.
    public internal(set) var conditionStack = [Bool]()

    // Currently executed script.
    public internal(set) var script: Script = Script()
    // Current opcode.
    public internal(set) var opCode: OpCode = OpCode.OP_0
    // Current payload for any "push data" operation.
    // public var data
    // Current opcode index in _script.
    public internal(set) var opIndex: Int = 0
    // Index of last OP_CODESEPARATOR
    public internal(set) var lastCodeSepartorIndex: Int = 0

    // Keeps number of executed operations to check for limit.
    public internal(set) var opCount: Int = 0

    // Transaction, utxo, index for CHECKSIG operations
    public var transaction: Transaction?
    public var utxoToVerify: TransactionOutput?
    public var inputIndex: UInt32 = 0xffffffff

    // Constants
    private let blobFalse: Data = Data()
    private let blobZero: Data = Data()
    private let blobTrue: Data = Data(bytes: [UInt8(1)])

    public var shouldExecute: Bool {
        return !conditionStack.contains(false)
    }

    func normalized(_ index: Int) -> Int {
        return (index < 0) ? stack.count + index : index
    }

    internal func pushToStack(_ bool: Bool) {
        stack.append(bool ? blobTrue : blobFalse)
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
