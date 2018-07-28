//
//  TransactionOutput.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/11.
//  Copyright © 2018 Kishikawa Katsumi
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

    public init(value: Int64, lockingScript: Data) {
        self.value = value
        self.lockingScript = lockingScript
    }

    public init() {
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
