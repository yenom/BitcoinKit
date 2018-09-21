//
//  ScriptMachine.swift
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
public struct ScriptMachine {

    public init() { }

    public static func verifyTransaction(signedTx: Transaction, inputIndex: UInt32, utxo: TransactionOutput, blockTimeStamp: UInt32 = UInt32(NSTimeIntervalSince1970)) throws -> Bool {
        // Sanity check: transaction and its input should be consistent.
        guard inputIndex < signedTx.inputs.count else {
            throw ScriptMachineError.exception("Transaction and valid inputIndex are required for script verification.")
        }
        let context: ScriptExecutionContext = ScriptExecutionContext(transaction: signedTx, utxoToVerify: utxo, inputIndex: inputIndex)!
        context.blockTimeStamp = blockTimeStamp

        let txInput: TransactionInput = signedTx.inputs[Int(inputIndex)]
        guard let unlockScript = Script(data: txInput.signatureScript), let lockScript = Script(data: utxo.lockingScript) else {
            throw ScriptMachineError.error("Both lock script and sig script must be valid.")
        }

        return try verify(lockScript: lockScript, unlockScript: unlockScript, context: context)
    }

    public static func verify(lockScript: Script, unlockScript: Script, context: ScriptExecutionContext) throws -> Bool {
        // First step: run the input script which typically places signatures, pubkeys and other static data needed for outputScript.
        try run(unlockScript, context: context)

        // Make a copy of the stack if we have P2SH script.
        // We will run deserialized P2SH script on this stack.
        let stackForP2SH: [Data] = context.stack

        // Second step: run output script to see that the input satisfies all conditions laid in the output script.
        try run(lockScript, context: context)

        // We need to have something on stack
        guard !context.stack.isEmpty else {
            throw ScriptMachineError.error("Stack is empty after script execution.")
        }

        // The last value must be true.
        guard context.bool(at: -1) else {
            throw ScriptMachineError.error("Last item on the stack is false.")
        }

        // Additional validation for spend-to-script-hash transactions:
        if context.shouldVerifyP2SH() && lockScript.isPayToScriptHashScript {
            guard unlockScript.isDataOnly else {
                throw ScriptMachineError.error("Input script for P2SH spending must be literals-only.")
            }
            let deserializedLockScript = try context.deserializeP2SHLockScript(stackForP2SH: stackForP2SH)
            try run(deserializedLockScript, context: context)

            // We need to have something on stack
            guard !context.stack.isEmpty else {
                throw ScriptMachineError.error("Stack is empty after script execution.")
            }

            // The last value must be YES.
            guard context.bool(at: -1) else {
                throw ScriptMachineError.error("Last item on the stack is false.")
            }
        } else {
            if context.verbose {
                print("context.shouldVerifyP2SH : ", context.shouldVerifyP2SH(), "isP2SH : ", lockScript.isPayToScriptHashScript)
            }
        }

        // If nothing failed, validation passed.
        return true
    }

    public static func run(_ script: Script, context: ScriptExecutionContext) throws {
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
