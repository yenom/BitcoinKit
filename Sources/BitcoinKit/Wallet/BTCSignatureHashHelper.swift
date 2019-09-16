//
//  BTCSignatureHashHelper.swift
//  
//  Copyright © 2019 BitcoinKit developers
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

/// Helper model that creates a BTC transaction's signature hash.
/// ```
/// // Initialize a helper
/// let helper = BTCSignatureHashHelper(hashType: SighashType.BCH.ALL)
///
/// // Create a transaction's signature hash for utxos[0].
/// let sighash: Data = helper.createSignatureHash(of: tx, for: utxos[0].output, inputIndex: 0)
/// ```
public struct BTCSignatureHashHelper: SignatureHashHelper {
    public let zero: Data = Data(repeating: 0, count: 32)
    public let one: Data = Data(repeating: 1, count: 1) + Data(repeating: 0, count: 31)

    public let hashType: SighashType
    public init(hashType: SighashType.BTC) {
        self.hashType = hashType
    }

    /// Create the transaction input to be signed
    public func createSigningInput(of txin: TransactionInput, from utxoOutput: TransactionOutput) -> TransactionInput {
        let subScript = Script(data: utxoOutput.lockingScript)!
        try! subScript.deleteOccurrences(of: .OP_CODESEPARATOR)
        return TransactionInput(previousOutput: txin.previousOutput,
                                signatureScript: subScript.data,
                                sequence: txin.sequence)
    }

    /// Create a blank transaction input
    public func createBlankInput(of txin: TransactionInput) -> TransactionInput {
        let sequence: UInt32
        if hashType.isNone || hashType.isSingle {
            sequence = 0
        } else {
            sequence = txin.sequence
        }
        return TransactionInput(previousOutput: txin.previousOutput,
                                signatureScript: Data(),
                                sequence: sequence)
    }

    /// Create the transaction inputs
    public func createInputs(of tx: Transaction, for utxoOutput: TransactionOutput, inputIndex: Int) -> [TransactionInput] {
        // If SIGHASH_ANYONECANPAY flag is set, only the input being signed is serialized
        if hashType.isAnyoneCanPay {
            return [createSigningInput(of: tx.inputs[inputIndex], from: utxoOutput)]
        }

        // Otherwise, all inputs are serialized
        var inputs: [TransactionInput] = []
        for i in 0..<tx.inputs.count {
            let txin = tx.inputs[i]
            if i == inputIndex {
                inputs.append(createSigningInput(of: txin, from: utxoOutput))
            } else {
                inputs.append(createBlankInput(of: txin))
            }
        }
        return inputs
    }

    /// Create the transaction outputs
    public func createOutputs(of tx: Transaction, inputIndex: Int) -> [TransactionOutput] {
        if hashType.isNone {
            // Wildcard payee - we can pay anywhere.
            return []
        } else if hashType.isSingle {
            // Single mode assumes we sign an output at the same index as an input.
            // All outputs before the one we need are blanked out. All outputs after are simply removed.
            // Only lock-in the txout payee at same index as txin.
            // This is equivalent to replacing outputs with (i-1) empty outputs and a i-th original one.
            let myOutput = tx.outputs[inputIndex]
            return Array(repeating: TransactionOutput(), count: inputIndex) + [myOutput]
        } else {
            return tx.outputs
        }
    }

    /// Create the signature hash of the BTC transaction
    ///
    /// - Parameters:
    ///   - tx: Transaction to be signed
    ///   - utxoOutput: TransactionOutput to be signed
    ///   - inputIndex: The index of the transaction output to be signed
    /// - Returns: The signature hash for the transaction to be signed.
    public func createSignatureHash(of tx: Transaction, for utxoOutput: TransactionOutput, inputIndex: Int) -> Data {
        // If inputIndex is out of bounds, BitcoinABC is returning a 256-bit little-endian 0x01 instead of failing with error.
        guard inputIndex < tx.inputs.count else {
            //  tx.inputs[inputIndex] out of range
            return one
        }

        // Check for invalid use of SIGHASH_SINGLE
        guard !(hashType.isSingle && inputIndex < tx.outputs.count) else {
            //  tx.outputs[inputIndex] out of range
            return one
        }

        // Modified Raw Transaction to be serialized
        let rawTransaction = Transaction(version: tx.version,
                              inputs: createInputs(of: tx, for: utxoOutput, inputIndex: inputIndex),
                              outputs: createOutputs(of: tx, inputIndex: inputIndex),
                              lockTime: tx.lockTime)
        var data: Data = rawTransaction.serialized()

        data += hashType.uint32
        let hash = Crypto.sha256sha256(data)
        return hash
    }
}
