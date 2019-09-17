//
//  BCHSignatureHashHelper.swift
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

/// Helper model that creates a BCH transaction's signature hash.
/// ```
/// // Initialize a helper
/// let helper = BCHSignatureHashHelper(hashType: SighashType.BCH.ALL)
///
/// // Create a transaction's signature hash for utxos[0].
/// let sighash: Data = helper.createSignatureHash(of: tx, for: utxos[0].output, inputIndex: 0)
/// ```
public struct BCHSignatureHashHelper: SignatureHashHelper {
    public let zero: Data = Data(repeating: 0, count: 32)
    public let one: Data = Data(repeating: 1, count: 1) + Data(repeating: 0, count: 31)

    public let hashType: SighashType
    public init(hashType: SighashType.BCH) {
        self.hashType = hashType
    }

    /// Create the hash of the transaction's previous outpoints
    public func createPrevoutHash(of tx: Transaction) -> Data {
        // if the ANYONECANPAY flag is set, returns uint256 of 0x0000......0000.
        if hashType.isAnyoneCanPay {
            return zero
        }

        // If the ANYONECANPAY flag is not set,
        // hashPrevouts is the double SHA256 of the serialization of all input outpoints
        let serializedPrevouts: Data = tx.inputs.reduce(Data()) { $0 + $1.previousOutput.serialized() }
        return Crypto.sha256sha256(serializedPrevouts)
    }

    /// Create the hash of the sequences of the transaction's inputs
    public func createSequenceHash(of tx: Transaction) -> Data {
        // if the ANYONECANPAY flag is set, hashSequence is a uint256 of 0x0000......0000
        if hashType.isAnyoneCanPay {
            return zero
        }
        // if the SINGLE flag is set, hashSequence is a uint256 of 0x0000......0000
        if hashType.isSingle {
            return zero
        }
        // if the NONE flag is set, hashSequence is a uint256 of 0x0000......0000
        if hashType.isNone {
            return zero
        }

        // If none of the ANYONECANPAY, SINGLE, NONE sighash type is set,
        // hashSequence is the double SHA256 of the serialization of nSequence of all inputs
        let serializedSequence: Data = tx.inputs.reduce(Data()) { $0 + $1.sequence }
        return Crypto.sha256sha256(serializedSequence)
    }

    /// Create the hash of the transaction's outputs
    public func createOutputsHash(of tx: Transaction, index: Int) -> Data {
        if !hashType.isSingle
            && !hashType.isNone {
            // If the sighash type is neither SINGLE nor NONE, hashOutputs is the double SHA256 of the serialization of all output amounts (8-byte little endian) paired up with their scriptPubKey (serialized as scripts inside CTxOuts)
            let serializedOutputs: Data = tx.outputs.reduce(Data()) { $0 + $1.serialized() }
            return Crypto.sha256sha256(serializedOutputs)
        } else if hashType.isSingle && index < tx.outputs.count {
            // If sighash type is SINGLE and the input index is smaller than the number of outputs, hashOutputs is the double SHA256 of the output amount with scriptPubKey of the same index as the input
            let serializedOutput = tx.outputs[index].serialized()
            return Crypto.sha256sha256(serializedOutput)
        } else {
            // Otherwise, hashOutputs is a uint256 of 0x0000......0000.
            return zero
        }
    }

    /// Create the signature hash of the BCH transaction
    ///
    /// - Parameters:
    ///   - tx: Transaction to be signed
    ///   - utxoOutput: TransactionOutput to be signed
    ///   - inputIndex: The index of the transaction output to be signed
    /// - Returns: The signature hash for the transaction to be signed.
    public func createSignatureHash(of tx: Transaction, for utxo: TransactionOutput, inputIndex: Int) -> Data {
        // "txin" ≒ "utxo"
        // "txin" is an input of this tx
        // "utxo" is an output of the prev tx
        // Currently not handling "inputIndex is out of range error" because BitcoinABC implementation is not handling this.
        let txin = tx.inputs[inputIndex]

        var data = Data()
        // 1. nVersion (4-byte)
        data += tx.version
        // 2. hashPrevouts
        data += createPrevoutHash(of: tx)
        // 3. hashSequence
        data += createSequenceHash(of: tx)
        // 4. outpoint [of the input txin]
        data += txin.previousOutput.serialized()
        // 5. scriptCode [of the input txout]
        data += utxo.scriptCode()
        // 6. value [of the input txout] (8-byte)
        data += utxo.value
        // 7. nSequence [of the input txin] (4-byte)
        data += txin.sequence
        // 8. hashOutputs
        data += createOutputsHash(of: tx, index: inputIndex)
        // 9. nLocktime (4-byte)
        data += tx.lockTime
        // 10. Sighash types [This time input] (4-byte)
        data += hashType.uint32
        let hash = Crypto.sha256sha256(data)
        return hash
    }
}
