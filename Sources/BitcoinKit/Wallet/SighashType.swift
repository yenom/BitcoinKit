//
//  SighashType.swift
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

private let SIGHASH_ALL: UInt8 = 0x01 // 00000001
private let SIGHASH_NONE: UInt8 = 0x02 // 00000010
private let SIGHASH_SINGLE: UInt8 = 0x03 // 00000011
private let SIGHASH_FORK_ID: UInt8 = 0x40 // 01000000
private let SIGHASH_ANYONECANPAY: UInt8 = 0x80 // 10000000

private let SIGHASH_OUTPUT_MASK: UInt8 = 0x1f // 00011111

public protocol SighashType {
    var rawValue: UInt8 { get }
}
public extension SighashType {
    var uint8: UInt8 { return rawValue }
    var uint32: UInt32 { return UInt32(rawValue) }

    private var outputType: UInt8 {
        return self.uint8 & SIGHASH_OUTPUT_MASK
    }
    var isAll: Bool {
        return outputType == SIGHASH_ALL
    }
    var isSingle: Bool {
        return outputType == SIGHASH_SINGLE
    }
    var isNone: Bool {
        return outputType == SIGHASH_NONE
    }

    var hasForkId: Bool {
        return (self.uint8 & SIGHASH_FORK_ID) != 0
    }
    var isAnyoneCanPay: Bool {
        return (self.uint8 & SIGHASH_ANYONECANPAY) != 0
    }
}

extension UInt8 {
    @available(*, deprecated, message: "Use hashType.uint8 instead")
    public init(_ hashType: SighashType) {
        self = hashType.uint8
    }
}

extension UInt32 {
    @available(*, deprecated, message: "Use hashType.uint32 instead")
    public init(_ hashType: SighashType) {
        self = UInt32(UInt8(hashType))
    }
}

extension SighashType {
    public typealias BCH = BCHSighashType
    public typealias BTC = BTCSighashType
}

// MARK: BCH SighashType
public enum BCHSighashType: SighashType {
    case ALL, NONE, SINGLE, ALL_ANYONECANPAY, NONE_ANYONECANPAY, SINGLE_ANYONECANPAY
    public init?(rawValue: UInt8) {
        switch rawValue {
        case BCHSighashType.ALL.rawValue: self = .ALL
        case BCHSighashType.NONE.rawValue: self = .NONE
        case BCHSighashType.SINGLE.rawValue: self = .SINGLE
        case BCHSighashType.ALL_ANYONECANPAY.rawValue: self = .ALL_ANYONECANPAY
        case BCHSighashType.NONE_ANYONECANPAY.rawValue: self = .NONE_ANYONECANPAY
        case BCHSighashType.SINGLE_ANYONECANPAY.rawValue: self = .SINGLE_ANYONECANPAY
        default: return nil
        }
    }

    public var rawValue: UInt8 {
        switch self {
        case .ALL: return SIGHASH_FORK_ID + SIGHASH_ALL // 01000001
        case .NONE: return SIGHASH_FORK_ID + SIGHASH_NONE // 01000010
        case .SINGLE: return SIGHASH_FORK_ID + SIGHASH_SINGLE // 01000011
        case .ALL_ANYONECANPAY: return SIGHASH_FORK_ID + SIGHASH_ALL + SIGHASH_ANYONECANPAY // 11000001
        case .NONE_ANYONECANPAY: return SIGHASH_FORK_ID + SIGHASH_NONE + SIGHASH_ANYONECANPAY // 11000010
        case .SINGLE_ANYONECANPAY: return SIGHASH_FORK_ID + SIGHASH_SINGLE + SIGHASH_ANYONECANPAY // 11000011
        }
    }
}

// MARK: BTC SighashType
public enum BTCSighashType: SighashType {
    case ALL, NONE, SINGLE, ALL_ANYONECANPAY, NONE_ANYONECANPAY, SINGLE_ANYONECANPAY
    public init?(rawValue: UInt8) {
        switch rawValue {
        case BTCSighashType.ALL.rawValue: self = .ALL
        case BTCSighashType.NONE.rawValue: self = .NONE
        case BTCSighashType.SINGLE.rawValue: self = .SINGLE
        case BTCSighashType.ALL_ANYONECANPAY.rawValue: self = .ALL_ANYONECANPAY
        case BTCSighashType.NONE_ANYONECANPAY.rawValue: self = .NONE_ANYONECANPAY
        case BTCSighashType.SINGLE_ANYONECANPAY.rawValue: self = .SINGLE_ANYONECANPAY
        default: return nil
        }
    }

    public var rawValue: UInt8 {
        switch self {
        case .ALL: return SIGHASH_ALL // 00000001
        case .NONE: return SIGHASH_NONE // 00000010
        case .SINGLE: return SIGHASH_FORK_ID + SIGHASH_SINGLE // 00000011
        case .ALL_ANYONECANPAY: return SIGHASH_ALL + SIGHASH_ANYONECANPAY // 10000001
        case .NONE_ANYONECANPAY: return SIGHASH_NONE + SIGHASH_ANYONECANPAY // 10000010
        case .SINGLE_ANYONECANPAY: return SIGHASH_SINGLE + SIGHASH_ANYONECANPAY // 10000011
        }
    }
}
