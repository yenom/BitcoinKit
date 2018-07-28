//
//  TransactionInput.swift
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

public struct TransactionInput {
    /// The previous output transaction reference, as an OutPoint structure
    public let previousOutput: TransactionOutPoint
    /// The length of the signature script
    public var scriptLength: VarInt {
        return VarInt(signatureScript.count)
    }
    /// Computational Script for confirming transaction authorization
    public let signatureScript: Data
    /// Transaction version as defined by the sender. Intended for "replacement" of transactions when information is updated before inclusion into a block.
    public let sequence: UInt32

    public init(previousOutput: TransactionOutPoint, signatureScript: Data, sequence: UInt32) {
        self.previousOutput = previousOutput
        self.signatureScript = signatureScript
        self.sequence = sequence
    }

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
        return TransactionInput(previousOutput: previousOutput, signatureScript: signatureScript, sequence: sequence)
    }
}
