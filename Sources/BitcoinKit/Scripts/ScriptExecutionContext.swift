//
//  ScriptExecutionContext.swift
//
//  Copyright © 2018 BitcoinKit developers
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

    // Keeps number of executed operations to check for limit.
    public internal(set) var opCount: Int = 0

    // Transaction, utxo, index for CHECKSIG operations
    public private(set) var transaction: Transaction?
    public private(set) var utxoToVerify: TransactionOutput?
    public private(set) var txinToVerify: TransactionInput?
    public private(set) var inputIndex: UInt32 = 0xffffffff

    // A timestamp of the current block. Default is current timestamp.
    // This is used to test for P2SH scripts or other changes in the protocol that may happen in the future.
    public var blockTimeStamp: UInt32 = UInt32(Date().timeIntervalSince1970)

    // Constants
    private let blobFalse: Data = Data()
    private let blobZero: Data = Data()
    private let blobTrue: Data = Data([UInt8(1)])

    // If verbose is true, stack will be printed each time OP_CODEs are executed
    public var verbose: Bool = false

    public init(isDebug: Bool = false) {
        self.verbose = isDebug
    }
    public init?(transaction: Transaction, utxoToVerify: TransactionOutput, inputIndex: UInt32) {
        guard transaction.inputs.count > inputIndex else {
            return nil
        }
        self.transaction = transaction
        self.utxoToVerify = utxoToVerify
        self.txinToVerify = transaction.inputs[Int(inputIndex)]
        self.inputIndex = inputIndex
    }
    public var shouldExecute: Bool {
        return !conditionStack.contains(false)
    }

    public func shouldVerifyP2SH() -> Bool {
        return blockTimeStamp >= BTC_BIP16_TIMESTAMP
    }

    private func normalized(_ index: Int) -> Int {
        return (index < 0) ? stack.count + index : index
    }

    // stack
    public func pushToStack(_ bool: Bool) {
        stack.append(bool ? blobTrue : blobFalse)
    }
    public func pushToStack(_ n: Int32) throws {
        stack.append(BigNumber(n.littleEndian).data)
    }
    public func pushToStack(_ data: Data) throws {
        guard data.count <= BTC_MAX_SCRIPT_ELEMENT_SIZE else {
            throw ScriptMachineError.error("PushedData size is too big.")
        }
        stack.append(data)
    }
    public func resetStack() {
        stack = []
        altStack = []
        conditionStack = []
    }
    public func swapDataAt(i: Int, j: Int) {
        stack.swapAt(normalized(i), normalized(j))
    }

    public func assertStackHeightGreaterThanOrEqual(_ n: Int) throws {
        guard stack.count >= n else {
            throw OpCodeExecutionError.opcodeRequiresItemsOnStack(n)
        }
    }

    public func assertAltStackHeightGreaterThanOrEqual(_ n: Int) throws {
        guard altStack.count >= n else {
            throw OpCodeExecutionError.error("Operation requires \(n) items on altstack.")
        }
    }

    // OpCount
    public func incrementOpCount(by i: Int = 1) throws {
        opCount += i
        guard opCount <= BTC_MAX_OPS_PER_SCRIPT else {
            throw OpCodeExecutionError.error("Exceeded the allowed number of operations per script.")
        }
    }

    public func deserializeP2SHLockScript(stackForP2SH: [Data]) throws -> Script {
        var stackForP2SH: [Data] = stackForP2SH

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

    public func number(at i: Int) throws -> Int32 {
        let data: Data = stack[normalized(i)]
        guard data.count <= 4 else {
            throw OpCodeExecutionError.invalidBignum
        }

        return BigNumber(data).int32
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
        var desc: String = ""
        for data in stack.reversed() {
            let hex = data.hex
            var contents: String = "0x" + hex

            if hex.count > 20 {
                let first = hex.prefix(5)
                let last = hex.suffix(5)
                contents = "\(first)..\(last) [\(data.count)bytes]"
            }

            if contents == "0x" {
                contents = "NULL [FALSE/0]"
            }

            if contents == "0x01" {
                contents = "0x01 [TRUE/1]"
            }

            for _ in 0...(24 - contents.count) / 2 {
                contents = " \(contents) "
            }
            desc += "| \(contents) |\n"
        }
        var base: String = ""
        (0...14).forEach { _ in
            base = "=\(base)="
        }
        return desc + base + "\n"
    }
}
