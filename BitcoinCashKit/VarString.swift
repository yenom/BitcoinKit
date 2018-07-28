//
//  VarString.swift
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

/// Variable length string can be stored using a variable length integer followed by the string itself.
public struct VarString: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public let length: VarInt
    public let value: String

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(_ value: String) {
        self.value = value
        length = VarInt(value.data(using: .ascii)!.count)
    }

    public func serialized() -> Data {
        var data = Data()
        data += length.serialized()
        data += value
        return data
    }
}

extension VarString: CustomStringConvertible {
    public var description: String {
        return "\(value)"
    }
}
