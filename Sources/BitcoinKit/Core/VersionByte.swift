//
//  VersionByte.swift
//
//  Copyright © 2018 BitcoinKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
