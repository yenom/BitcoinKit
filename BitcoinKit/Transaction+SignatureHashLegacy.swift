//
//  Transaction+SignatureHashLegacy.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/06.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

extension Transaction {
    public func signatureHashLegacy(for utxoToSign: TransactionOutput, inputIndex: Int, hashType: SighashType) -> Data {
        // Can't have index greater than num of inputs
        guard inputIndex < inputs.count else {
            return Data()
        }
        var inputsToSign: [TransactionInput] = inputs
        var outputsToSign: [TransactionOutput] = outputs
        var sighash: Data {
            let tx = Transaction(version: version, inputs: inputsToSign, outputs: outputsToSign, lockTime: lockTime)
            let unsignedRawTx: Data = tx.serialized() + UInt32(hashType)
            return Crypto.sha256sha256(unsignedRawTx)
        }

        // Blank out other inputs' signature scripts
        // and replace our input script with a subscript (which is typically a full output script from the previous transaction).
        for i in 0..<inputsToSign.count {
            let txin = inputsToSign[i]
            // TODO: Remove OP_CODESEPARATOR from lockingScript
            let subScript: Data = utxoToSign.lockingScript // .deleteOccurrencesOfOpcode(OP_CODESEPARATOR)
            let script: Data = (i == inputIndex) ? subScript : Data()
            inputsToSign[i] = txin.sigChanged(with: script)
        }

        if hashType.isNone {
            // Wildcard payee - we can pay anywhere.
            outputsToSign = []

            // Blank out others' input sequence numbers to let others update transaction at will.
            inputsToSign = inputsToSign.map { $0.sequenceChanged(with: 0) }
        }

        if hashType.isSingle {
            let outputIndex = inputIndex
            // If outputIndex is out of bounds, BitcoinQT is returning a 256-bit little-endian 0x01 instead of failing with error.
            // We should do the same to stay compatible.
            guard outputIndex < outputs.count else {
                // 0x0100000000000000000000000000000000000000000000000000000000000000
                return Data(repeating: 1, count: 1) + Data(repeating: 0, count: 31)
            }

            // Single mode assumes we sign an output at the same index as an input.
            // All outputs before the one we need are blanked out. All outputs after are simply removed.
            // Only lock-in the txout payee at same index as txin.
            // This is equivalent to replacing outputs with (i-1) empty outputs and a i-th original one.
            let myOutput = outputs[outputIndex]
            outputsToSign = Array(repeating: TransactionOutput(), count: outputIndex) + [myOutput]

            // Blank out others' input sequence numbers to let others update transaction at will.
            inputsToSign = inputsToSign.map { $0.sequenceChanged(with: 0) }
        }

        if hashType.isAnyoneCanPay {
            let input = inputsToSign[inputIndex]
            inputsToSign = [input]
        }

        return sighash
    }
}

private extension TransactionInput {
    func sigChanged(with script: Data) -> TransactionInput {
        return TransactionInput(previousOutput: previousOutput, signatureScript: script, sequence: sequence)
    }

    func sequenceChanged(with seq: UInt32) -> TransactionInput {
        return TransactionInput(previousOutput: previousOutput, signatureScript: signatureScript, sequence: seq)
    }
}
