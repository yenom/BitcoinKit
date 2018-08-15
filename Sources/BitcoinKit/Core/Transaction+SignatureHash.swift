//
//  Transaction+SignatureHash.swift
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

private let zero: Data = Data(repeating: 0, count: 32)
private let one: Data = Data(repeating: 1, count: 1) + Data(repeating: 0, count: 31)

extension Transaction {
    internal func getPrevoutHash(hashType: SighashType) -> Data {
        if !hashType.isAnyoneCanPay {
            // If the ANYONECANPAY flag is not set, hashPrevouts is the double SHA256 of the serialization of all input outpoints
            let serializedPrevouts: Data = inputs.reduce(Data()) { $0 + $1.previousOutput.serialized() }
            return Crypto.sha256sha256(serializedPrevouts)
        } else {
            // if ANYONECANPAY then uint256 of 0x0000......0000.
            return zero
        }
    }

    internal func getSequenceHash(hashType: SighashType) -> Data {
        if !hashType.isAnyoneCanPay
            && !hashType.isSingle
            && !hashType.isNone {
            // If none of the ANYONECANPAY, SINGLE, NONE sighash type is set, hashSequence is the double SHA256 of the serialization of nSequence of all inputs
            let serializedSequence: Data = inputs.reduce(Data()) { $0 + $1.sequence }
            return Crypto.sha256sha256(serializedSequence)
        } else {
            // Otherwise, hashSequence is a uint256 of 0x0000......0000
            return zero
        }
    }

    internal func getOutputsHash(index: Int, hashType: SighashType) -> Data {
        if !hashType.isSingle
            && !hashType.isNone {
            // If the sighash type is neither SINGLE nor NONE, hashOutputs is the double SHA256 of the serialization of all output amounts (8-byte little endian) paired up with their scriptPubKey (serialized as scripts inside CTxOuts)
            let serializedOutputs: Data = outputs.reduce(Data()) { $0 + $1.serialized() }
            return Crypto.sha256sha256(serializedOutputs)
        } else if hashType.isSingle && index < outputs.count {
            // If sighash type is SINGLE and the input index is smaller than the number of outputs, hashOutputs is the double SHA256 of the output amount with scriptPubKey of the same index as the input
            let serializedOutput = outputs[index].serialized()
            return Crypto.sha256sha256(serializedOutput)
        } else {
            // Otherwise, hashOutputs is a uint256 of 0x0000......0000.
            return zero
        }
    }

    internal func signatureHashLegacy(for utxo: TransactionOutput, inputIndex: Int, hashType: SighashType) -> Data {
        // If inputIndex is out of bounds, BitcoinABC is returning a 256-bit little-endian 0x01 instead of failing with error.
        guard inputIndex < inputs.count else {
            //  tx.inputs[inputIndex] out of range
            return one
        }

        // Check for invalid use of SIGHASH_SINGLE
        guard !(hashType.isSingle && inputIndex < outputs.count) else {
            //  tx.outputs[inputIndex] out of range
            return one
        }

        // Transaction is struct(value type), so it's ok to use self as an arg
        let txSigSerializer = TransactionSignatureSerializer(tx: self, utxo: utxo, inputIndex: inputIndex, hashType: hashType)
        var data: Data = txSigSerializer.serialize()
        data += UInt32(hashType)
        let hash = Crypto.sha256sha256(data)
        return hash
    }

    public func signatureHash(for utxo: TransactionOutput, inputIndex: Int, hashType: SighashType) -> Data {
        // If hashType doesn't have a fork id, use legacy signature hash
        guard hashType.hasForkId else {
            return signatureHashLegacy(for: utxo, inputIndex: inputIndex, hashType: hashType)
        }

        // "txin" ≒ "utxo"
        // "txin" is an input of this tx
        // "utxo" is an output of the prev tx
        // Currently not handling "inputIndex is out of range error" because BitcoinABC implementation is not handling this.
        let txin = inputs[inputIndex]

        var data = Data()
        // 1. nVersion (4-byte)
        data += version
        // 2. hashPrevouts
        data += getPrevoutHash(hashType: hashType)
        // 3. hashSequence
        data += getSequenceHash(hashType: hashType)
        // 4. outpoint [of the input txin]
        data += txin.previousOutput.serialized()
        // 5. scriptCode [of the input txout]
        data += utxo.scriptCode()
        // 6. value [of the input txout] (8-byte)
        data += utxo.value
        // 7. nSequence [of the input txin] (4-byte)
        data += txin.sequence
        // 8. hashOutputs
        data += getOutputsHash(index: inputIndex, hashType: hashType)
        // 9. nLocktime (4-byte)
        data += lockTime
        // 10. Sighash types [This time input] (4-byte)
        data += UInt32(hashType)
        let hash = Crypto.sha256sha256(data)
        return hash
    }
}
