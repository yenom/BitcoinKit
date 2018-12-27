//
//  TransactionSignatureSerializer.swift
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

public struct TransactionSignatureSerializer {
    var tx: Transaction
    var utxo: TransactionOutput
    var inputIndex: Int
    var hashType: SighashType

    // input should be modified before sign
    internal func modifiedInput(for i: Int) -> TransactionInput {
        let txin = tx.inputs[i]
        let sigScript: Data
        let sequence: UInt32

        if i == inputIndex {
            let subScript = Script(data: utxo.lockingScript)
            try! subScript?.deleteOccurrences(of: .OP_CODESEPARATOR)
            sigScript = subScript?.data ?? Data()
            sequence = txin.sequence
        } else if hashType.isNone || hashType.isSingle {
            // If hashtype is NONE or SINGLE, blank out others' input sequence numbers to let others update transaction at will.
            sigScript = Data()
            sequence = 0
        } else {
            sigScript = Data()
            sequence = txin.sequence
        }
        return TransactionInput(previousOutput: txin.previousOutput, signatureScript: sigScript, sequence: sequence)
    }

    public func serialize() -> Data {
        let inputsToSerialize: [TransactionInput]
        let outputsToSerialize: [TransactionOutput]
        // In case of SIGHASH_ANYONECANPAY, only the input being signed is serialized
        if hashType.isAnyoneCanPay {
            inputsToSerialize = [modifiedInput(for: inputIndex)]
        } else {
            inputsToSerialize = (0..<tx.inputs.count).map { modifiedInput(for: $0) }
        }

        if hashType.isNone {
            // Wildcard payee - we can pay anywhere.
            outputsToSerialize = []
        } else if hashType.isSingle {
            // Single mode assumes we sign an output at the same index as an input.
            // All outputs before the one we need are blanked out. All outputs after are simply removed.
            // Only lock-in the txout payee at same index as txin.
            // This is equivalent to replacing outputs with (i-1) empty outputs and a i-th original one.
            let myOutput = tx.outputs[inputIndex]
            outputsToSerialize = Array(repeating: TransactionOutput(), count: inputIndex) + [myOutput]
        } else {
            outputsToSerialize = tx.outputs
        }

        let tmp = Transaction(version: tx.version,
                              timestamp: tx.timestamp,
                                        inputs: inputsToSerialize,
                                        outputs: outputsToSerialize,
                                        lockTime: tx.lockTime)
        return tmp.serialized()
    }
}
