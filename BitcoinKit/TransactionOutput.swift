//
//  TransactionOutput.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/11.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

// TODO: scriptLengthはcomputed propertyで良いのではと思ったけど、deserializeするときには必要なのか。initするときには必要なくしたい。
public struct TransactionOutput {
    /// Transaction Value
    public let value: Int64
    /// Length of the pk_script
    public var scriptLength: VarInt {
        return VarInt(lockingScript.count)
    }
    /// Usually contains the public key as a Bitcoin script setting up conditions to claim this output
    public let lockingScript: Data

    public func scriptCode() -> Data {
        var data = Data()
        data += scriptLength.serialized()
        data += lockingScript
        return data
    }

    init(value: Int64, lockingScript: Data) {
        self.value = value
        self.lockingScript = lockingScript
    }

    init() {
        self.init(value: 0, lockingScript: Data())
    }

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
        return TransactionOutput(value: value, lockingScript: lockingScript)
    }
}
