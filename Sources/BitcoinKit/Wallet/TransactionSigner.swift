//
//  TransactionSigner.swift
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

public enum TransactionSignerError: Error {
    case noKeyFound
}

/// Helper class that performs Bitcoin transaction signing.
public final class TransactionSigner {
    /// Transaction plan.
    public let plan: TransactionPlan
    /// Transaction being signed.
    public let transaction: Transaction
    /// Signature Hash Helper
    public let sighashHelper: SignatureHashHelper

    /// List of signed inputs.
    private var signedInputs: [TransactionInput]
    /// Signed transaction
    private var signedTransaction: Transaction {
        return Transaction(
            version: transaction.version,
            inputs: signedInputs,
            outputs: transaction.outputs,
            lockTime: transaction.lockTime)
    }

    public init(plan: TransactionPlan, transaction: Transaction, sighashHelper: SignatureHashHelper) {
        self.plan = plan
        self.transaction = transaction
        self.signedInputs = transaction.inputs
        self.sighashHelper = sighashHelper
    }

    public func sign(with keys: [PrivateKey]) throws -> Transaction {
        // Sign
        for (i, utxo) in plan.utxos.enumerated() {
            // Select key
            let pubkeyHash: Data = Script.getPublicKeyHash(from: utxo.output.lockingScript)

            let keysOfUtxo: [PrivateKey] = keys.filter { $0.publicKey().pubkeyHash == pubkeyHash }
            guard let key = keysOfUtxo.first else {
                throw TransactionSignerError.noKeyFound
            }

            // Sign transaction hash
            let sighash: Data = sighashHelper.createSignatureHash(of: transaction, for: utxo.output, inputIndex: i)
            let signature: Data = try Crypto.sign(sighash, privateKey: key)
            let txin = signedInputs[i]
            let pubkey = key.publicKey()

            // Create Signature Script
            let sigWithHashType: Data = signature + [sighashHelper.hashType.uint8]
            let unlockingScript: Script = try Script()
                .appendData(sigWithHashType)
                .appendData(pubkey.data)

            // Update TransactionInput
            signedInputs[i] = TransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript.data, sequence: txin.sequence)
        }
        return signedTransaction

    }
}
