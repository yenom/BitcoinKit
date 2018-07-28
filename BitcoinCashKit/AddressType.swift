//
//  AddressType.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/03.
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

public class AddressType {
    static let pubkeyHash: AddressType = PubkeyHash()
    static let scriptHash: AddressType = ScriptHash()

    var versionByte: UInt8 { return 0 }
    var versionByte160: UInt8 { return versionByte + 0 }
    var versionByte192: UInt8 { return versionByte + 1 }
    var versionByte224: UInt8 { return versionByte + 2 }
    var versionByte256: UInt8 { return versionByte + 3 }
    var versionByte320: UInt8 { return versionByte + 4 }
    var versionByte384: UInt8 { return versionByte + 5 }
    var versionByte448: UInt8 { return versionByte + 6 }
    var versionByte512: UInt8 { return versionByte + 7 }
}

extension AddressType: Equatable {
    // swiftlint:disable:next operator_whitespace
    public static func ==(lhs: AddressType, rhs: AddressType) -> Bool {
        return lhs.versionByte == rhs.versionByte
    }
}
public class PubkeyHash: AddressType {
    public override var versionByte: UInt8 { return 0 }
}
public class ScriptHash: AddressType {
    public override var versionByte: UInt8 { return 8 }
}
