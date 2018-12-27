//
//  MockHelper.swift
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

public struct MockHelper {

    public static func createUtxo(lockScript: Script) -> UnspentTransaction {
        let outputMock = TransactionOutput(value: 100_000_000, lockingScript: lockScript.data)
        let outpointMock = TransactionOutPoint(hash: Data(), index: 0)
        return UnspentTransaction(output: outputMock, outpoint: outpointMock)
    }

    public static func createTransaction(utxo: UnspentTransaction) -> Transaction {
        let toAddress: Address = try! AddressFactory.create("1Bp9U1ogV3A14FMvKbRJms7ctyso4Z4Tcx")
        let changeAddress: Address = try! AddressFactory.create("1FQc5LdgGHMHEN9nwkjmz6tWkxhPpxBvBU")
        // 1. inputs
        let unsignedInputs = [TransactionInput(previousOutput: utxo.outpoint,
                                               signatureScript: Data(),
                                               sequence: UInt32.max)]

        // 2. outputs
        // 2-1. amount, change, fee
        let amount: UInt64 = 10_000
        let fee: UInt64 = 1000
        let change: UInt64 = utxo.output.value - amount - fee

        // 2-2. Script
        let lockingScriptTo = Script(address: toAddress)!
        let lockingScriptChange = Script(address: changeAddress)!

        // 2-3. TransactionOutput
        let toOutput = TransactionOutput(value: amount, lockingScript: lockingScriptTo.data)
        let changeOutput = TransactionOutput(value: change, lockingScript: lockingScriptChange.data)

        // 3. Tx
        let tx = Transaction(version: 1, timestamp: UInt32(Date(timeIntervalSinceNow: 0).timeIntervalSince1970), inputs: unsignedInputs, outputs: [toOutput, changeOutput], lockTime: 0)
        return tx
    }

    public static func updateTransaction(_ tx: Transaction, unlockScriptData: Data) -> Transaction {
        let i = 0
        var inputs = tx.inputs

        // Sequence may need to be updated
        let txin = inputs[i]
        inputs[i] = TransactionInput(previousOutput: txin.previousOutput,
                                     signatureScript: unlockScriptData,
                                     sequence: txin.sequence)

        return Transaction(version: tx.version,
                           timestamp: tx.timestamp,
                           inputs: inputs,
                           outputs: tx.outputs,
                           lockTime: tx.lockTime)
    }

    public static func verifySingleKey(lockScript: Script, unlockScriptBuilder: MockUnlockScriptBuilder, key: MockKey, verbose: Bool = true) throws -> Bool {
        // mocks
        let utxoMock: UnspentTransaction = MockHelper.createUtxo(lockScript: lockScript)
        let txMock: Transaction = MockHelper.createTransaction(utxo: utxoMock)

        // signature, unlockScript(scriptSig)
        let hashType = SighashType.BCH.ALL
        let signature: Data = key.privkey.sign(txMock, utxoToSign: utxoMock, hashType: hashType)
        let sigWithHashType: Data = signature + UInt8(hashType)
        let pair: SigKeyPair = SigKeyPair(sigWithHashType, key.pubkey)
        let unlockScript: Script = unlockScriptBuilder.build(pairs: [pair])
        // signed tx
        let signedTxMock = MockHelper.updateTransaction(txMock, unlockScriptData: unlockScript.data)

        // context
        let context = ScriptExecutionContext(transaction: signedTxMock, utxoToVerify: utxoMock.output, inputIndex: 0)!
        context.verbose = verbose

        // script test
        return try ScriptMachine.verify(lockScript: lockScript, unlockScript: unlockScript, context: context)
    }

    public static func verifyMultiKey(lockScript: Script, unlockScriptBuilder: MockUnlockScriptBuilder, keys: [MockKey], verbose: Bool = true) throws -> Bool {
        // mocks
        let utxoMock: UnspentTransaction = MockHelper.createUtxo(lockScript: lockScript)
        let txMock: Transaction = MockHelper.createTransaction(utxo: utxoMock)

        // signature, unlockScript(scriptSig)
        let hashType = SighashType.BCH.ALL
        var sigKeyPairs: [SigKeyPair] = []
        for key in keys {
            let signature: Data = key.privkey.sign(txMock, utxoToSign: utxoMock, hashType: hashType)
            let sigWithHashType: Data = signature + UInt8(hashType)
            sigKeyPairs.append(SigKeyPair(sigWithHashType, key.pubkey))
        }

        let unlockScript: Script = unlockScriptBuilder.build(pairs: sigKeyPairs)
        // signed tx
        let signedTxMock = MockHelper.updateTransaction(txMock, unlockScriptData: unlockScript.data)

        // context
        let context = ScriptExecutionContext(transaction: signedTxMock, utxoToVerify: utxoMock.output, inputIndex: 0)!
        context.verbose = verbose

        // script test
        return try ScriptMachine.verify(lockScript: lockScript, unlockScript: unlockScript, context: context)
    }

}
