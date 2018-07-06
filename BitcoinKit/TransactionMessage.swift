//
//  TransactionMessage.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/30.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

/// tx describes a bitcoin transaction, in reply to getdata
public struct TransactionMessage {
    /// Transaction data format version (note, this is signed)
    public let version: Int32
    /// If present, always 0001, and indicates the presence of witness data
    // public let flag: UInt16 // If present, always 0001, and indicates the presence of witness data
    /// Number of Transaction inputs (never zero)
    public var txInCount: VarInt {
        return VarInt(inputs.count)
    }
    /// A list of 1 or more transaction inputs or sources for coins
    public let inputs: [TransactionInput]
    /// Number of Transaction outputs
    public var txOutCount: VarInt {
        return VarInt(outputs.count)
    }
    /// A list of 1 or more transaction outputs or destinations for coins
    public let outputs: [TransactionOutput]
    /// A list of witnesses, one for each input; omitted if flag is omitted above
    // public let witnesses: [TransactionWitness] // A list of witnesses, one for each input; omitted if flag is omitted above
    /// The block number or timestamp at which this transaction is unlocked:
    public let lockTime: UInt32

    public var txHash: Data {
        return Crypto.sha256sha256(serialized())
    }

    public var txID: String {
        return Data(txHash.reversed()).hex
    }

    init(version: Int32, inputs: [TransactionInput], outputs: [TransactionOutput], lockTime: UInt32) {
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.lockTime = lockTime
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

    public static func deserialize(_ data: Data) -> TransactionMessage {
        let byteStream = ByteStream(data)
        return deserialize(byteStream)
    }

    static func deserialize(_ byteStream: ByteStream) -> TransactionMessage {
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
        return TransactionMessage(version: version, inputs: inputs, outputs: outputs, lockTime: lockTime)
    }
}
