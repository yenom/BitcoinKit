//
//  VersionByte.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/08.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public class VersionByte {
    static let pubkeyHash160: UInt8 = PubkeyHash160().bytes
    static let scriptHash160: UInt8 = ScriptHash160().bytes
    var bytes: UInt8 {
        return type.rawValue + size.rawValue
    }

    public var type: TypeBits { return .pubkeyHash }
    public var size: SizeBits { return .size160 }

    public static func getSize(from versionByte: UInt8) -> Int {
        guard let sizeBits = SizeBits(rawValue: versionByte & 0x07) else {
            return 0
        }
        switch sizeBits {
        case .size160:
            return 20
        case .size192:
            return 24
        case .size224:
            return 28
        case .size256:
            return 32
        case .size320:
            return 40
        case .size384:
            return 48
        case .size448:
            return 56
        case .size512:
            return 64
        }
    }

    // First 1 bit is zero
    // Next 4bits
    public enum TypeBits: UInt8 {
        case pubkeyHash = 0
        case scriptHash = 8
    }

    // The least 3bits
    public enum SizeBits: UInt8 {
        case size160 = 0
        case size192 = 1
        case size224 = 2
        case size256 = 3
        case size320 = 4
        case size384 = 5
        case size448 = 6
        case size512 = 7
    }
}

public class PubkeyHash160: VersionByte {
    public override var size: SizeBits { return .size160 }
    public override var type: TypeBits { return .pubkeyHash }
}
public class ScriptHash160: VersionByte {
    public override var size: SizeBits { return .size160 }
    public override var type: TypeBits { return .scriptHash }
}
