//
//  BigNumber.swift
//  BitcoinCashKit
//
//  Created by Shun Usami on 2018/07/31.
//  Copyright © 2018 BitcoinCashKit developers. All rights reserved.
//

import Foundation
import BitcoinCashKit.Private

public struct BigNumber {
    public var uint32: UInt32
    public var data: Data
    public init(_ uint32: UInt32) {
        self.uint32 = uint32
        self.data = _BigNumber.integer2BN(uint32)
    }

    public init(_ data: Data) {
        self.data = data
        self.uint32 = _BigNumber.bn2Integer(data)
    }
}

//public struct BigNumber: BigNumberProtocol {
//    public var compact: UInt32
//    public var uint32: UInt32
//    public var int32: Int32
//    public var uint64: UInt64
//    public var int64: Int64
//    public var hex: String
//    public var decimalString: String
//    public var signedLittleEndian: Data
//    public var unsignedBigEndian: Data
//    
//    // Initialized with OpenSSL representation of bignum.
//    // var BIGNUM: BIGNUM { get }
//
//    public var isZero: Bool
//    public var isOne: Bool
//    
////    public static let zero: BigNumber
////    public static let one: BigNumber
////    public static let negativeOne: BigNumber
//    public init() {}
//    public init(compact: UInt32) {}
//    public init(uint32: UInt32) {}
//    public init(int32: Int32) {}
//    public init(uint64: UInt64) {}
//    public init(int64: Int64) {}
//    public init(string: String, base: Int) {}
//    // Same as init(string:base:16)
//    public init(hex: String) {}
//    // Same as init(string:base:10)
//    public init(decimalString: String) {}
//    public init(signedLittleEndian: Data) {}
//    public init(unsignedBigEndian: Data) {}
//    // public init(BIGNUM: BIGNUM) {}
//    
//    public func string(in base: Int) -> String { return "" }
//}

// TODO: Comparable, Equatable

// [0...7] : exponent of base256 ("number of bytes of N")
// [8] : sign of N
// [9...31] : mantissa

// The "compact" format is a representation of a whole
// number N using an unsigned 32bit number similar to a
// floating point format.
// The most significant 8 bits are the unsigned exponent of base 256.
// This exponent can be thought of as "number of bytes of N".
// The lower 23 bits are the mantissa.
// Bit number 24 (0x800000) represents the sign of N.
// N = (-1^sign) * mantissa * 256^(exponent-3)
//
// Satoshi's original implementation used BN_bn2mpi() and BN_mpi2bn().
// MPI uses the most significant bit of the first byte as sign.
// Thus 0x1234560000 is compact (0x05123456) -> 5 + 0x123456 -> 0x123456 + 0000 [(5-3)*2]
// and  0xc0de000000 is compact (0x0600c0de) -> 6 + 0xc0de -> 0xc0de + 000000 [(6-3)*2]
// (0x05c0de00) would be -0x40de000000 -> 5 + sign + 0x40de00 -> 0x40de00 + 0000 [(5-3)*2]
//
// Bitcoin only uses this "compact" format for encoding difficulty
// targets, which are unsigned 256bit quantities.  Thus, all the
// complexities of the sign bit and using base 256 are probably an
// implementation accident.
//
// This implementation directly uses shifts instead of going
// through an intermediate MPI representation.
