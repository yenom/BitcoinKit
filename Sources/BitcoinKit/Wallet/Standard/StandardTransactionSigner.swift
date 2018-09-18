//
//  StandardTransactionSigner.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/18.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

public struct StandardTransactionSigner: WalletTransactionSigner {
    public func sign(_ unsignedTransaction: UnsignedTransaction, with keys: [PrivateKey]) throws -> Transaction {
        // Define Transaction
        var signingInputs: [TransactionInput]
        var signingTransaction: Transaction {
            let tx: Transaction = unsignedTransaction.tx
            return Transaction(version: tx.version, inputs: signingInputs, outputs: tx.outputs, lockTime: tx.lockTime)
        }

        // Sign
        signingInputs = unsignedTransaction.tx.inputs
        let hashType = SighashType.BCH.ALL
        for (i, utxo) in unsignedTransaction.utxos.enumerated() {
            // Select key
            let pubkeyHash: Data = Script.getPublicKeyHash(from: utxo.output.lockingScript)

            let keysOfUtxo: [PrivateKey] = keys.filter { $0.publicKey().pubkeyHash == pubkeyHash }
            guard let key = keysOfUtxo.first else {
                continue
            }

            // Sign transaction hash
            let sighash: Data = signingTransaction.signatureHash(for: utxo.output, inputIndex: i, hashType: SighashType.BCH.ALL)
            let signature: Data = try Crypto.sign(sighash, privateKey: key)
            let txin = signingInputs[i]
            let pubkey = key.publicKey()

            // Create Signature Script
            let sigWithHashType: Data = signature + UInt8(hashType)
            let unlockingScript: Script = try Script()
                .appendData(sigWithHashType)
                .appendData(pubkey.data)

            // TODO: Update sequence
            // Update TransactionInput
            signingInputs[i] = TransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript.data, sequence: txin.sequence)
        }
        return signingTransaction

    }
}
