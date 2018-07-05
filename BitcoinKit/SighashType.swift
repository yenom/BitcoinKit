//
//  SighashType.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/30.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public struct SighashType {
    public static let SIGHASH_ALL: UInt8 = 0x01 // 00000001
    public static let SIGHASH_NONE: UInt8 = 0x02 // 00000010
    public static let SIGHASH_SINGLE: UInt8 = 0x03 // 00000011
    public static let SIGHASH_FORK_ID: UInt8 = 0x40 // 01000000
    public static let SIGHASH_ANYONECANPAY: UInt8 = 0x80 // 10000000

    public static let SIGHASH_OUTPUT_MASK: UInt8 = 0x1f // 00011111
}
