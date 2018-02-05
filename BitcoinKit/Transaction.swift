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

public struct TransactionInput {
    /// The previous output transaction reference, as an OutPoint structure
    public let previousOutput: TransactionOutPoint
    /// The length of the signature script
    public let scriptLength: VarInt
    /// Computational Script for confirming transaction authorization
    public let signatureScript: Data
    /// Transaction version as defined by the sender. Intended for "replacement" of transactions when information is updated before inclusion into a block.
    public let sequence: UInt32

    public func serialized() -> Data {
        var data = Data()
        data += previousOutput.serialized()
        data += scriptLength.serialized()
        data += signatureScript
        data += sequence
        return data
    }

    static func deserialize(_ byteStream: ByteStream) -> TransactionInput {
        let previousOutput = TransactionOutPoint.deserialize(byteStream)
        let scriptLength = byteStream.read(VarInt.self)
        let signatureScript = byteStream.read(Data.self, count: Int(scriptLength.underlyingValue))
        let sequence = byteStream.read(UInt32.self)
        return TransactionInput(previousOutput: previousOutput, scriptLength: scriptLength, signatureScript: signatureScript, sequence: sequence)
    }
}

public struct TransactionOutPoint {
    /// The hash of the referenced transaction.
    public let hash: Data
    /// The index of the specific output in the transaction. The first output is 0, etc.
    public let index: UInt32

    public func serialized() -> Data {
        var data = Data()
        data += hash.reversed()
        data += index
        return data
    }

    static func deserialize(_ byteStream: ByteStream) -> TransactionOutPoint {
        let hash = Data(byteStream.read(Data.self, count: 32).reversed())
        let index = byteStream.read(UInt32.self)
        return TransactionOutPoint(hash: hash, index: index)
    }
}

public struct TransactionOutput {
    /// Transaction Value
    public let value: Int64
    /// Length of the pk_script
    public let scriptLength: VarInt
    /// Usually contains the public key as a Bitcoin script setting up conditions to claim this output
    public let lockingScript: Data

    public func serialized() -> Data {
        var data = Data()
        data += value
        data += scriptLength.serialized()
        data += lockingScript
        return data
    }

    static func deserialize(_ byteStream: ByteStream) -> TransactionOutput {
        let value = byteStream.read(Int64.self)
        let scriptLength = byteStream.read(VarInt.self)
        let lockingScript = byteStream.read(Data.self, count: Int(scriptLength.underlyingValue))
        return TransactionOutput(value: value, scriptLength: scriptLength, lockingScript: lockingScript)
    }
}

public struct TransactionWitness {}
