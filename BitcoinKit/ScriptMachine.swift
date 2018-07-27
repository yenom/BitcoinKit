//
//  ScriptMachine.swift
//  BitcoinKit
//
//  Created by Akifumi Fujita on 2018/07/13.
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
//  This file has been modified by the BitcoinCashKit developers for the BitcoinCashKit project.
//  The original file was from the bitcoinj project (https://github.com/kishikawakatsumi/BitcoinKit).
//

import Foundation
import secp256k1

public enum ScriptVerification {
    case StrictEncoding // enforce strict conformance to DER and SEC2 for signatures and pubkeys (aka SCRIPT_VERIFY_STRICTENC)
    case EvenS // enforce lower S values (below curve halforder) in signatures (aka SCRIPT_VERIFY_EVEN_S, depends on STRICTENC)
}

public enum ScriptMachineError: Error {
    case exception(String)
    case error(String)
    case opcodeRequiresItemsOnStack(Int)
    case invalidBignum
}

// ScriptMachine is a stack machine (like Forth) that evaluates a predicate
// returning a bool indicating valid or not. There are no loops.
// You can -copy a machine which will copy all the parameters and the stack state.
class ScriptMachine {

    // Constants
    private let blobFalse: Data = Data()
    private let blobZero: Data = Data()
    private let blobTrue: Data = Data(bytes: [UInt8(1)])
    // TODO: check later
    private let bigNumberZero: Data = Data() + UInt64(0)
    private let bigNumberOne: Data = Data() + UInt64(1)
    private let bigNumberFalse: Data = Data() + UInt64(0)
    private let bigNumberTrue: Data = Data() + UInt64(1)

    // "To" transaction that is signed by an inputScript.
    // Required parameter.
    public var transaction: Transaction?

    // An index of the tx input in the `transaction`.
    // Required parameter.
    public var inputIndex: UInt32

    // A timestamp of the current block. Default is current timestamp.
    // This is used to test for P2SH scripts or other changes in the protocol that may happen in the future.
    // If not specified, defaults to current timestamp thus using the latest protocol rules.
    public var blockTimestamp: UInt32 = UInt32(NSTimeIntervalSince1970)

    private var context: ScriptExecutionContext = ScriptExecutionContext()
    public init() {
        inputIndex = 0xFFFFFFFF
    }

    // This will return nil if the transaction is nil, or inputIndex is out of bounds.
    // You can use -init if you want to run scripts without signature verification (so no transaction is needed).
    public convenience init?(tx: Transaction, inputIndex: UInt32) {
        // BitcoinQT would crash right before VerifyScript if the input index was out of bounds.
        // So even though it returns 1 from SignatureHash() function when checking for this condition,
        // it never actually happens. So we too will not check for it when calculating a hash.
        guard inputIndex < tx.inputs.count else {
            return nil
        }
        self.init()
        self.transaction = tx
        self.inputIndex = inputIndex
    }

    private func shouldVerifyP2SH() -> Bool {
        return blockTimestamp >= BTC_BIP16_TIMESTAMP
    }

    public func verify(with utxo: TransactionOutput) throws -> Bool {
        // Sanity check: transaction and its input should be consistent.
        guard let tx = transaction, inputIndex < tx.inputs.count else {
            throw ScriptMachineError.exception("Transaction and valid inputIndex are required for script verification.")
        }
        context.transaction = transaction
        context.utxoToVerify = utxo
        context.inputIndex = inputIndex

        let txInput: TransactionInput = tx.inputs[Int(inputIndex)]
        let unlockScript: Script = Script(data: txInput.signatureScript)! // TODO: txinput.signatureScript should be Script class
        let lockScript: Script = Script(data: utxo.lockingScript)! // TODO: utxo.lockingScript should be Script class

        // First step: run the input script which typically places signatures, pubkeys and other static data needed for outputScript.
        try runScript(unlockScript)

        // Second step: run output script to see that the input satisfies all conditions laid in the output script.
        try runScript(lockScript)

        // We need to have something on stack
        guard !context.stack.isEmpty else {
            throw ScriptMachineError.error("Stack is empty after script execution.")
        }

        // The last value must be true.
        guard context.bool(at: -1) else {
            throw ScriptMachineError.error("Last item on the stack is false.")
        }

        // Additional validation for spend-to-script-hash transactions:
        if shouldVerifyP2SH() && lockScript.isPayToScriptHashScript {
            guard unlockScript.isDataOnly else {
                throw ScriptMachineError.error("Input script for P2SH spending must be literals-only.")
            }
            let deserializedLockScript = try context.deserializeP2SHLockScript()
            try runScript(deserializedLockScript)

            // We need to have something on stack
            guard !context.stack.isEmpty else {
                throw ScriptMachineError.error("Stack is empty after script execution.")
            }

            // The last value must be YES.
            guard context.bool(at: -1) else {
                throw ScriptMachineError.error("Last item on the stack is false.")
            }
        }

        // If nothing failed, validation passed.
        return true
    }

    public func runScript(_ script: Script) throws {
        guard script.data.count <= BTC_MAX_SCRIPT_SIZE else {
            throw ScriptMachineError.exception("Script binary is too long.")
        }

        // Altstack should be reset between script runs.
        try script.execute(with: context)
    }
}

private extension Array {
    subscript (normalized index: Int) -> Element {
        return (index < 0) ? self[count + index] : self[index]
    }
}
