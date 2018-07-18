//
//  TestHelpers.swift
//  BitcoinKitTests
//
//  Created by Shun Usami on 2018/07/08.
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
@testable import BitcoinKit

enum UtxoSelectError: Error {
    case insufficient
}

extension Array {
    // Slice Array
    // [0,1,2,3,4,5,6,7,8,9].eachSlices(3)
    // >
    // [[0, 1, 2], [1, 2, 3], [2, 3, 4], [3, 4, 5], [4, 5, 6], [5, 6, 7], [6, 7, 8], [7, 8, 9]]
    func eachSlices(_ num: Int) -> [[Element]] {
        let slices = (0...count - num).map { self[$0..<$0 + num].map { $0 } }
        return slices
    }
}

extension Array where Element == UnspentTransaction {
    func sum() -> Int64 {
        return reduce(0) { $0 + $1.output.value }
    }
}

public struct Fee {
    public static let feePerByte: Int64 = 1 // ideally get this value from Bitcoin node
    public static let dust: Int64 = 3 * 182 * feePerByte
    
    // size for txin(P2PKH) : 148 bytes
    // size for txout(P2PKH) : 34 bytes
    // cf. size for txin(P2SH) : not determined to one
    // cf. size for txout(P2SH) : 32 bytes
    // cf. size for txout(OP_RETURN + String) : Roundup([#characters]/32) + [#characters] + 11 bytes
    public static func calculate(nIn: Int, nOut: Int = 2, extraOutputSize: Int = 0) -> Int64 {
        var txsize: Int {
            return ((148 * nIn) + (34 * nOut) + 10) + extraOutputSize
        }
        return Int64(txsize) * feePerByte
    }
}

public func selectTx(from utxos: [UnspentTransaction], targetValue: Int64, dustThreshhold: Int64 = Fee.dust) throws -> (utxos: [UnspentTransaction], fee: Int64) {
    // if target value is zero, fee is zero
    guard targetValue > 0 else {
        return ([], 0)
    }
    
    // definitions for the following caluculation
    let doubleTargetValue = targetValue * 2
    var numOutputs = 2 // if allow multiple output, it will be changed.
    var numInputs = 2
    var fee: Int64 {
        return Fee.calculate(nIn: numInputs, nOut: numOutputs)
    }
    var targetWithFee: Int64 {
        return targetValue + fee
    }
    var targetWithFeeAndDust: Int64 {
        return targetWithFee + dustThreshhold
    }
    
    let sortedUtxos: [UnspentTransaction] = utxos.sorted(by: { $0.output.value < $1.output.value })
    
    // total values of utxos should be greater than targetValue
    guard sortedUtxos.sum() >= targetValue && sortedUtxos.count > 0 else {
        throw UtxoSelectError.insufficient
    }
    
    // difference from 2x targetValue
    func distFrom2x(_ val: Int64) -> Int64 {
        return abs(val - doubleTargetValue)
    }
    
    // 1. Find a combination of the fewest outputs that is
    //    (1) bigger than what we need
    //    (2) closer to 2x the amount,
    //    (3) and does not produce dust change.
    txN:do {
        for numTx in (1...sortedUtxos.count) {
            numInputs = numTx
            let nOutputsSlices = sortedUtxos.eachSlices(numInputs)
            var nOutputsInRange = nOutputsSlices.filter { $0.sum() >= targetWithFeeAndDust }
            nOutputsInRange.sort { distFrom2x($0.sum()) < distFrom2x($1.sum()) }
            if let nOutputs = nOutputsInRange.first {
                return (nOutputs, fee)
            }
        }
    }
    
    // 2. If not, find a combination of outputs that may produce dust change.
    txDiscardDust:do {
        for numTx in (1...sortedUtxos.count) {
            numInputs = numTx
            let nOutputsSlices = sortedUtxos.eachSlices(numInputs)
            let nOutputsInRange = nOutputsSlices.filter {
                return $0.sum() >= targetWithFee
            }
            if let nOutputs = nOutputsInRange.first {
                return (nOutputs, fee)
            }
        }
    }
    
    throw UtxoSelectError.insufficient
}

public func createUnsignedTx(toAddress: Address, amount: Int64, changeAddress: Address, utxos: [UnspentTransaction]) -> UnsignedTransaction {
    let (utxos, fee) = try! selectTx(from: utxos, targetValue: amount)
    let totalAmount: Int64 = utxos.reduce(0) { $0 + $1.output.value }
    let change: Int64 = totalAmount - amount - fee
    
    let toPubKeyHash: Data = toAddress.data
    let changePubkeyHash: Data = changeAddress.data
    
    let lockingScriptTo = Script.buildPublicKeyHashOut(pubKeyHash: toPubKeyHash)
    let lockingScriptChange = Script.buildPublicKeyHashOut(pubKeyHash: changePubkeyHash)
    
    let toOutput = TransactionOutput(value: amount, lockingScript: lockingScriptTo)
    let changeOutput = TransactionOutput(value: change, lockingScript: lockingScriptChange)
    
    // この後、signatureScriptやsequenceは更新される
    let unsignedInputs = utxos.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: Data(), sequence: UInt32.max) }
    let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: [toOutput, changeOutput], lockTime: 0)
    return UnsignedTransaction(tx: tx, utxos: utxos)
}

public func signTx(unsignedTx: UnsignedTransaction, keys: [PrivateKey]) -> Transaction {
    var inputsToSign = unsignedTx.tx.inputs
    var transactionToSign: Transaction {
        return Transaction(version: unsignedTx.tx.version, inputs: inputsToSign, outputs: unsignedTx.tx.outputs, lockTime: unsignedTx.tx.lockTime)
    }

    // Signing
    let hashType = SighashType.BCH.ALL
    for (i, utxo) in unsignedTx.utxos.enumerated() {
        let pubkeyHash: Data = Script.getPublicKeyHash(from: utxo.output.lockingScript)
        
        let keysOfUtxo: [PrivateKey] = keys.filter { $0.publicKey().pubkeyHash == pubkeyHash }
        guard let key = keysOfUtxo.first else {
            continue
        }
        
        let sighash: Data = transactionToSign.signatureHash(for: utxo.output, inputIndex: i, hashType: SighashType.BCH.ALL)
        let signature: Data = try! Crypto.sign(sighash, privateKey: key)
        let txin = inputsToSign[i]
        let pubkey = key.publicKey()
        
        var unlockingScript: Data = Data([UInt8(signature.count + 1)]) + signature + UInt8(hashType)
        unlockingScript += VarInt(pubkey.raw.count).serialized()
        unlockingScript += pubkey.raw
        
        // TODO: sequenceの更新
        inputsToSign[i] = TransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript, sequence: txin.sequence)
    }
    return transactionToSign
}
