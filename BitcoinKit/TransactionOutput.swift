//
//  TransactionOutput.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/11.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

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
