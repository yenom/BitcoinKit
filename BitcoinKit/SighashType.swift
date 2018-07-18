//
//  SighashType.swift
//  BitcoinKit
//
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

private let SIGHASH_ALL: UInt8 = 0x01 // 00000001
private let SIGHASH_NONE: UInt8 = 0x02 // 00000010
private let SIGHASH_SINGLE: UInt8 = 0x03 // 00000011
private let SIGHASH_FORK_ID: UInt8 = 0x40 // 01000000
private let SIGHASH_ANYONECANPAY: UInt8 = 0x80 // 10000000

private let SIGHASH_OUTPUT_MASK: UInt8 = 0x1f // 00011111

public struct SighashType {
    fileprivate let uint8: UInt8
    init(_ uint8: UInt8) {
        self.uint8 = uint8
    }

    private var outputType: UInt8 {
        return self.uint8 & SIGHASH_OUTPUT_MASK
    }
    public var isAll: Bool {
        return outputType == SIGHASH_ALL
    }
    public var isSingle: Bool {
        return outputType == SIGHASH_SINGLE
    }
    public var isNone: Bool {
        return outputType == SIGHASH_NONE
    }

    public var hasForkId: Bool {
        return (self.uint8 & SIGHASH_FORK_ID) != 0
    }
    public var isAnyoneCanPay: Bool {
        return (self.uint8 & SIGHASH_ANYONECANPAY) != 0
    }

    public struct BCH {
        public static let ALL: SighashType = SighashType(SIGHASH_FORK_ID + SIGHASH_ALL) // 01000001
        public static let NONE: SighashType = SighashType(SIGHASH_FORK_ID + SIGHASH_NONE) // 01000010
        public static let SINGLE: SighashType = SighashType(SIGHASH_FORK_ID + SIGHASH_SINGLE) // 01000011
        public static let ALL_ANYONECANPAY: SighashType = SighashType(SIGHASH_FORK_ID + SIGHASH_ALL + SIGHASH_ANYONECANPAY) // 11000001
        public static let NONE_ANYONECANPAY: SighashType = SighashType(SIGHASH_FORK_ID + SIGHASH_NONE + SIGHASH_ANYONECANPAY) // 11000010
        public static let SINGLE_ANYONECANPAY: SighashType = SighashType(SIGHASH_FORK_ID + SIGHASH_SINGLE + SIGHASH_ANYONECANPAY) // 11000011
    }

    public struct BTC {
        public static let ALL: SighashType = SighashType(SIGHASH_ALL) // 00000001
        public static let NONE: SighashType = SighashType(SIGHASH_NONE) // 00000010
        public static let SINGLE: SighashType = SighashType(SIGHASH_SINGLE) // 00000011
        public static let ALL_ANYONECANPAY: SighashType = SighashType(SIGHASH_ALL + SIGHASH_ANYONECANPAY) // 10000001
        public static let NONE_ANYONECANPAY: SighashType = SighashType(SIGHASH_NONE + SIGHASH_ANYONECANPAY) // 10000010
        public static let SINGLE_ANYONECANPAY: SighashType = SighashType(SIGHASH_SINGLE + SIGHASH_ANYONECANPAY) // 10000011
    }
}

extension UInt8 {
    init(_ hashType: SighashType) {
        self = hashType.uint8
    }
}

extension UInt32 {
    init(_ hashType: SighashType) {
        self = UInt32(UInt8(hashType))
    }
}
