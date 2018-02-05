//
//  Signature.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/30.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public struct Signature {
    public static let SIGHASH_ALL: UInt8 = 0x01;
    public static let SIGHASH_NONE: UInt8 = 0x02;
    public static let SIGHASH_SINGLE: UInt8 = 0x03;
    public static let SIGHASH_ANYONECANPAY: UInt8 = 0x80;
}
