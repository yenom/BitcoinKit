//
//  Transaction.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/30.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

// TODO: txInCount, txOutCountとかはcomputed propertyで良いのでは。と思ったけど、deserializeするときには必要なのか。initするときには必要なくしたい。

/// tx describesa bitcoin transaction, in reply to getdata
public struct Transaction {
    /// Transaction data format version (note, this is signed)
    public let version: Int32
    /// If present, always 0001, and indicates the presence of witness data
    // public let flag: UInt16 // If present, always 0001, and indicates the presence of witness data
    /// Number of Transaction inputs (never zero)
    public let txInCount: VarInt
    /// A list of 1 or more transaction inputs or sources for coins
    public let inputs: [TransactionInput]
    /// Number of Transaction outputs
    public let txOutCount: VarInt
    /// A list of 1 or more transaction outputs or destinations for coins
    public let outputs: [TransactionOutput]
    /// A list of witnesses, one for each input; omitted if flag is omitted above
    // public let witnesses: [TransactionWitness] // A list of witnesses, one for each input; omitted if flag is omitted above
    /// The block number or timestamp at which this transaction is unlocked:
    public let lockTime: UInt32

    public var internalTxID: Data {
        return Crypto.sha256sha256(serialized())
    }

    public var txID: String {
        return Data(internalTxID.reversed()).hex
    }

    public func serialized() -> Data {
        var data = Data()
        data += version
        data += txInCount.serialized()
        data += inputs.flatMap { $0.serialized() }
        data += txOutCount.serialized()
        data += outputs.flatMap { $0.serialized() }
        data += lockTime
        return data
    }

    public static func deserialize(_ data: Data) -> Transaction {
        let byteStream = ByteStream(data)
        return deserialize(byteStream)
    }

    static func deserialize(_ byteStream: ByteStream) -> Transaction {
        let version = byteStream.read(Int32.self)
        let txInCount = byteStream.read(VarInt.self)
        var inputs = [TransactionInput]()
        for _ in 0..<Int(txInCount.underlyingValue) {
            inputs.append(TransactionInput.deserialize(byteStream))
        }
        let txOutCount = byteStream.read(VarInt.self)
        var outputs = [TransactionOutput]()
        for _ in 0..<Int(txOutCount.underlyingValue) {
            outputs.append(TransactionOutput.deserialize(byteStream))
        }
        let lockTime = byteStream.read(UInt32.self)
        return Transaction(version: version, txInCount: txInCount, inputs: inputs, txOutCount: txOutCount, outputs: outputs, lockTime: lockTime)
    }
}

extension Transaction {
    public func signatureHashLegacy(for utxoToSign: TransactionOutput, inputIndex: Int, hashType: UInt8) -> Data {
        // Can't have index greater than num of inputs
        guard inputIndex < inputs.count else {
            return Data()
        }

        var copiedInputs = inputs
        var copiedOutputs = outputs
        for i in 0..<copiedInputs.count {
            let txin = copiedInputs[i]
            let newTxin: TransactionInput
            if i == inputIndex {
                newTxin = TransactionInput(previousOutput: txin.previousOutput, scriptLength: utxoToSign.scriptLength, signatureScript: utxoToSign.lockingScript, sequence: txin.sequence)
            } else {
                newTxin = TransactionInput(previousOutput: txin.previousOutput, scriptLength: 0, signatureScript: Data(), sequence: txin.sequence)
            }
            copiedInputs[i] = newTxin
        }

        switch hashType & Signature.SIGHASH_OUTPUT_MASK {
        case Signature.SIGHASH_NONE:
            // Wildcard payee - we can pay anywhere.
            copiedOutputs = []

            // Blank out others' input sequence numbers to let others update transaction at will.
            for i in 0..<copiedInputs.count {
                let txin = copiedInputs[i]
                let newTxin: TransactionInput = TransactionInput(previousOutput: txin.previousOutput, scriptLength: txin.scriptLength, signatureScript: txin.signatureScript, sequence: 0)
                copiedInputs[i] = newTxin
            }
        case Signature.SIGHASH_SINGLE:
            // Single mode assumes we sign an output at the same index as an input.
            // Outputs before the one we need are blanked out. All outputs after are simply removed.
            // Only lock-in the txout payee at same index as txin.
            let outputIndex = inputIndex

            // If outputIndex is out of bounds, BitcoinQT is returning a 256-bit little-endian 0x01 instead of failing with error.
            // We should do the same to stay compatible.
            guard outputIndex < outputs.count else {
                // 0x0100000000000000000000000000000000000000000000000000000000000000
                return Data(repeating: 1, count: 1) + Data(repeating: 0, count: 31)
            }

            // All outputs before the one we need are blanked out. All outputs after are simply removed.
            // This is equivalent to replacing outputs with (i-1) empty outputs and a i-th original one.
            let myOutput = outputs[outputIndex]
            copiedOutputs = []
            for _ in 0..<outputIndex {
                copiedOutputs.append(TransactionOutput(value: 0, scriptLength: 0, lockingScript: Data()))
            }
            copiedOutputs.append(myOutput)

            // Blank out others' input sequence numbers to let others update transaction at will.
            for i in 0..<copiedInputs.count {
                let txin = copiedInputs[i]
                let newTxin: TransactionInput = TransactionInput(previousOutput: txin.previousOutput, scriptLength: txin.scriptLength, signatureScript: txin.signatureScript, sequence: 0)
                copiedInputs[i] = newTxin
            }
        default:
            ()
        }

        if (hashType & Signature.SIGHASH_ANYONECANPAY) != 0 {
            let input = copiedInputs[inputIndex]
            copiedInputs = [input]
        }

        let tx = Transaction(version: version, txInCount: VarInt(copiedInputs.count), inputs: copiedInputs, txOutCount: VarInt(copiedOutputs.count), outputs: copiedOutputs, lockTime: lockTime)
        var data = Data()
        data += tx.serialized()
        data += UInt32(hashType).littleEndian

        let hash = Crypto.sha256sha256(data)
        return hash
    }

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
        if (hashType & Signature.SIGHASH_ANYONECANPAY) == 0 {
            // If the ANYONECANPAY flag is not set, hashPrevouts is the double SHA256 of the serialization of all input outpoints
            let serializedPrevouts: Data = reduce(Data()) { $0 + $1.previousOutput.serialized() }
            return Crypto.sha256sha256(serializedPrevouts)
        } else {
            // if ANYONECANPAY then uint256 of 0x0000......0000.
            return Data(repeating: 0, count: 32)
        }
    }

    func hashSequence(_ hashType: UInt8) -> Data {
        if (hashType & Signature.SIGHASH_ANYONECANPAY) == 0
            && (hashType & 0x1f) != Signature.SIGHASH_SINGLE
            && (hashType & 0x1f) != Signature.SIGHASH_NONE {
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
        if (hashType & 0x1f) != Signature.SIGHASH_SINGLE
            && (hashType & 0x1f) != Signature.SIGHASH_NONE {
            // If the sighash type is neither SINGLE nor NONE, hashOutputs is the double SHA256 of the serialization of all output amounts (8-byte little endian) paired up with their scriptPubKey (serialized as scripts inside CTxOuts)
            let serializedOutputs: Data = reduce(Data()) { $0 + $1.serialized() }
            return Crypto.sha256sha256(serializedOutputs)

        } else if (hashType & 0x1f) == Signature.SIGHASH_SINGLE && inputIndex < count {
            // If sighash type is SINGLE and the input index is smaller than the number of outputs, hashOutputs is the double SHA256 of the output amount with scriptPubKey of the same index as the input
            let serializedOutput = self[inputIndex].serialized()
            return Crypto.sha256sha256(serializedOutput)
        } else {
            // Otherwise, hashOutputs is a uint256 of 0x0000......0000.
            return Data(repeating: 0, count: 32)
        }
    }
}
