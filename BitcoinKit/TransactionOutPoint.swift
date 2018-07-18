//
//  TransactionOutPoint.swift
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

public struct TransactionOutPoint {
    /// The hash of the referenced transaction.
    public let hash: Data
    /// The index of the specific output in the transaction. The first output is 0, etc.
    public let index: UInt32

    public init(hash: Data, index: UInt32) {
        self.hash = hash
        self.index = index
    }

    public func serialized() -> Data {
        var data = Data()
        data += hash
        data += index
        return data
    }

    static func deserialize(_ byteStream: ByteStream) -> TransactionOutPoint {
        let hash = Data(byteStream.read(Data.self, count: 32).reversed())
        let index = byteStream.read(UInt32.self)
        return TransactionOutPoint(hash: hash, index: index)
    }
}
