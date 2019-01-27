//
//  AddressType.swift
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

public class AddressType {
    static let pubkeyHash: AddressType = PubkeyHash()
    static let scriptHash: AddressType = ScriptHash()
    static let stealthHash: AddressType = StealthHash()

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
    public static func == (lhs: AddressType, rhs: AddressType) -> Bool {
        return lhs.versionByte == rhs.versionByte
    }
}
public class PubkeyHash: AddressType {
    public override var versionByte: UInt8 { return 0 }
}
public class ScriptHash: AddressType {
    public override var versionByte: UInt8 { return 8 }
}
public class StealthHash: AddressType {
    public override var versionByte: UInt8 { return 16 }
}
