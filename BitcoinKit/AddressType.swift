//
//  AddressType.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/03.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
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
