//
//  Transaction+SignatureHash.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/05.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

extension Transaction {
    public func signatureHash(for utxoToSign: TransactionOutput, inputIndex: Int, hashType: UInt8) -> Data {
        // Can't have index greater than num of inputs
        guard inputIndex < inputs.count else {
            return Data()
        }

        // input and utxoToSign is basically the same thing.
        // input is txin of this tx, whereas utxoToSign is txout of the prev tx
        let input = inputs[inputIndex]

        var data = Data()
        // 1. nVersion (4-byte)
        data += version
        // 2. hashPrevouts
        data += inputs.hashPrevouts(hashType)
        // 3. hashSequence
        data += inputs.hashSequence(hashType)
        // 4. outpoint [of the input txin]
        data += input.previousOutput.serialized()
        // 5. scriptCode [of the input txout]
        data += utxoToSign.scriptCode()
        // 6. value [of the input txout] (8-byte)
        data += utxoToSign.value
        // 7. nSequence [of the input txin] (4-byte)
        data += input.sequence
        // 8. hashOutputs
        data += outputs.hashOutputs(hashType, inputIndex: inputIndex)
        // 9. nLocktime (4-byte)
        data += lockTime
        // 10. Sighash types [This time input] (4-byte)
        data += UInt32(hashType)

        let hash = Crypto.sha256sha256(data)
        return hash
    }
}

private extension Array where Element == TransactionInput {
    func hashPrevouts(_ hashType: UInt8) -> Data {
        if (hashType & SighashType.SIGHASH_ANYONECANPAY) == 0 {
            // If the ANYONECANPAY flag is not set, hashPrevouts is the double SHA256 of the serialization of all input outpoints
            let serializedPrevouts: Data = reduce(Data()) { $0 + $1.previousOutput.serialized() }
            return Crypto.sha256sha256(serializedPrevouts)
        } else {
            // if ANYONECANPAY then uint256 of 0x0000......0000.
            return Data(repeating: 0, count: 32)
        }
    }

    func hashSequence(_ hashType: UInt8) -> Data {
        if (hashType & SighashType.SIGHASH_ANYONECANPAY) == 0
            && (hashType & 0x1f) != SighashType.SIGHASH_SINGLE
            && (hashType & 0x1f) != SighashType.SIGHASH_NONE {
            // If none of the ANYONECANPAY, SINGLE, NONE sighash type is set, hashSequence is the double SHA256 of the serialization of nSequence of all inputs
            let serializedSequence: Data = reduce(Data()) { $0 + $1.sequence }
            return Crypto.sha256sha256(serializedSequence)
        } else {
            // Otherwise, hashSequence is a uint256 of 0x0000......0000
            return Data(repeating: 0, count: 32)
        }
    }
}

private extension Array where Element == TransactionOutput {
    func hashOutputs(_ hashType: UInt8, inputIndex: Int) -> Data {
        if (hashType & 0x1f) != SighashType.SIGHASH_SINGLE
            && (hashType & 0x1f) != SighashType.SIGHASH_NONE {
            // If the sighash type is neither SINGLE nor NONE, hashOutputs is the double SHA256 of the serialization of all output amounts (8-byte little endian) paired up with their scriptPubKey (serialized as scripts inside CTxOuts)
            let serializedOutputs: Data = reduce(Data()) { $0 + $1.serialized() }
            return Crypto.sha256sha256(serializedOutputs)

        } else if (hashType & 0x1f) == SighashType.SIGHASH_SINGLE && inputIndex < count {
            // If sighash type is SINGLE and the input index is smaller than the number of outputs, hashOutputs is the double SHA256 of the output amount with scriptPubKey of the same index as the input
            let serializedOutput = self[inputIndex].serialized()
            return Crypto.sha256sha256(serializedOutput)
        } else {
            // Otherwise, hashOutputs is a uint256 of 0x0000......0000.
            return Data(repeating: 0, count: 32)
        }
    }
}
