//
//  Transaction.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/30.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

/// tx describes a bitcoin transaction, in reply to getdata
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
    public func signatureHashLegacy(for inputUtxo: TransactionOutput, inputIndex: Int, hashType: UInt8) -> Data {
        return Data()
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
                newTxin = TransactionInput(previousOutput: txin.previousOutput, scriptLength: inputUtxo.scriptLength, signatureScript: inputUtxo.lockingScript, sequence: txin.sequence)
            } else {
                newTxin = TransactionInput(previousOutput: txin.previousOutput, scriptLength: 0, signatureScript: Data(), sequence: txin.sequence)
            }
            copiedInputs[i] = newTxin
        }

        // TODO: hashtype
        switch hashType & Signature.SIGHASH_OUTPUT_MASK {
        case Signature.SIGHASH_NONE:
            // TODO:
            ()
        case Signature.SIGHASH_SINGLE:
            // TODO:
            ()
        default:
            ()
        }

        if (hashType & Signature.SIGHASH_ANYONECANPAY != 0) {
            let input = copiedInputs[inputIndex]
            copiedInputs = [input]
        }

        let tx = Transaction(version: version, txInCount: VarInt(copiedInputs.count), inputs: copiedInputs, txOutCount: VarInt(copiedOutputs.count), outputs: copiedOutputs, lockTime: lockTime)
        var data = Data()
        data += tx.serialized()
        data += hashType

        let hash = Crypto.sha256sha256(data)
        return hash
    }

    public func signatureHash(for inputUtxo: TransactionOutput, inputIndex: Int, hashType: UInt8) -> Data {
        // Can't have index greater than num of inputs
        guard inputIndex < inputs.count else {
            return Data()
        }

        // input and inputUtxo is basically the same thing.
        // input is txin of this tx, whereas inputUtxo is txout of the prev tx
        let input = inputs[inputIndex]

        var data = Data()
        // 1. nVersion
        data += version
        // 2. hashPrevouts
        data += inputs.hashPrevouts(hashType)
        // 3. hashSequence
        data += inputs.hashSequence(hashType)
        // 4. outpoint [of the input txin]
        data += input.previousOutput.serialized()
        // 5. scriptCode [of the input txout]
        data += inputUtxo.scriptCode()
        // 6. value [of the input txout] TODO: (8-byte little endian)になっているか確認
        data += inputUtxo.value
        // 7. nSequence [of the input txin]
        data += input.sequence
        // 8. hashOutputs
        data += outputs.hashOutputs(hashType, inputIndex: inputIndex)
        // 9. nLocktime
        data += lockTime
        // 10. Sighash types [This time input]
        data += UInt32(hashType).littleEndian

        let hash = Crypto.sha256sha256(data)
        return hash
    }
}

private extension Array where Element == TransactionInput {
    func hashPrevouts(_ hashType: UInt8) -> Data {
        // TODO: if ANYONECANPAY then uint256 of 0x0000......0000.
        let serializedPrevouts: Data = reduce(Data()) { $0 + $1.previousOutput.serialized() }
        return Crypto.sha256sha256(serializedPrevouts)
    }

    func hashSequence(_ hashType: UInt8) -> Data {
        // TODO: if ANYONECANPAY, SINGLE, NONE then uint256 of 0x0000......0000.
        let serializedSequence: Data = reduce(Data()) { $0 + $1.sequence }
        return Crypto.sha256sha256(serializedSequence)
    }
}

private extension Array where Element == TransactionOutput {
    func hashOutputs(_ hashType: UInt8, inputIndex: Int) -> Data {
        let serializedOutputs: Data = reduce(Data()) { $0 + $1.serialized() }
        // TODO: if SINGLE then only self[inputIndex].serialized()
        //       else if NONE then uint256 of 0x0000......0000.
        return Crypto.sha256sha256(serializedOutputs)
    }
}
