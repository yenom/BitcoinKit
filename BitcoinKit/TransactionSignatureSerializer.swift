//
//  TransactionSignatureSerializer.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/06.
//  Copyright © 2018 Shun Usami
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

public struct TransactionSignatureSerializer {
    var tx: Transaction
    var utxo: TransactionOutput
    var inputIndex: Int
    var hashType: SighashType

    // input should be modified before sign
    internal func modifiedInput(for i: Int) -> TransactionInput {
        let txin = tx.inputs[i]
        let script: Data
        let sequence: UInt32

        if i == inputIndex {
            // TODO: Remove OP_CODESEPARATOR from lockingScript
            let subScript: Data = utxo.lockingScript // .deleteOccurrencesOfOpcode(OP_CODESEPARATOR)
            script = subScript
            sequence = txin.sequence
        } else if hashType.isNone || hashType.isSingle {
            // If hashtype is NONE or SINGLE, blank out others' input sequence numbers to let others update transaction at will.
            script = Data()
            sequence = 0
        } else {
            script = Data()
            sequence = txin.sequence
        }
        return TransactionInput(previousOutput: txin.previousOutput, signatureScript: script, sequence: sequence)
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
                                        inputs: inputsToSerialize,
                                        outputs: outputsToSerialize,
                                        lockTime: tx.lockTime)
        return tmp.serialized()
    }
}
