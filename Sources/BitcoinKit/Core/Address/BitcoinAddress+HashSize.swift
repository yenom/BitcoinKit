//
//  BitcoinAddress+HashSize.swift
// 
//  Copyright © 2019 BitcoinKit developers
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

extension BitcoinAddress {
    /// An object that represents the hash size of a cashaddr.
    ///
    /// The 3 least significant bits of VersionByte in cashaddr are the size bits.
    /// In most cases, the size of the hash is 160 bis, however different sizes
    /// are also possible.
    /// https://www.bitcoincash.org/spec/cashaddr.html
    public struct HashSize {
        public let rawValue: UInt8
        /// Creates a new HashSize instance with 3 bits value.
        ///
        /// Size bits are the least 3 bits of the version byte. So the rawValue
        /// should be 0-7.
        /// - Parameter rawValue: UInt8 value of the 3 bits.
        public init?(rawValue: UInt8) {
            guard [0, 1, 2, 3, 4, 5, 6, 7].contains(rawValue) else {
                return nil
            }
            self.rawValue = rawValue
        }

        /// Creates a new HashSize instance with the actual size of the hash.
        ///
        /// The hash size in bits can be 160, 192, 224, 256, 320, 384, 448 or 512.
        /// - Parameter sizeInBits: UInt8 value of the size of the hash in bits.
        public init?(sizeInBits: Int) {
            switch sizeInBits {
            case 160: rawValue = 0
            case 192: rawValue = 1
            case 224: rawValue = 2
            case 256: rawValue = 3
            case 320: rawValue = 4
            case 384: rawValue = 5
            case 448: rawValue = 6
            case 512: rawValue = 7
            default: return nil
            }
        }
    }
}

extension BitcoinAddress.HashSize {
    /// Hash size in bits
    public var sizeInBits: Int {
        switch rawValue {
        case 0: return 160
        case 1: return 192
        case 2: return 224
        case 3: return 256
        case 4: return 320
        case 5: return 384
        case 6: return 448
        case 7: return 512
        default: fatalError("Unsupported size bits")
        }
    }

    /// Hash size in bytes
    public var sizeInBytes: Int {
        return sizeInBits / 8
    }
}

extension BitcoinAddress.HashSize: Equatable {
    // swiftlint:disable operator_whitespace
    public static func ==(lhs: BitcoinAddress.HashSize, rhs: BitcoinAddress.HashSize) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension BitcoinAddress.HashSize {
    public static let bits160: BitcoinAddress.HashSize = BitcoinAddress.HashSize(sizeInBits: 160)!
    public static let bits192: BitcoinAddress.HashSize = BitcoinAddress.HashSize(sizeInBits: 192)!
    public static let bits224: BitcoinAddress.HashSize = BitcoinAddress.HashSize(sizeInBits: 224)!
    public static let bits256: BitcoinAddress.HashSize = BitcoinAddress.HashSize(sizeInBits: 256)!
    public static let bits320: BitcoinAddress.HashSize = BitcoinAddress.HashSize(sizeInBits: 320)!
    public static let bits384: BitcoinAddress.HashSize = BitcoinAddress.HashSize(sizeInBits: 384)!
    public static let bits448: BitcoinAddress.HashSize = BitcoinAddress.HashSize(sizeInBits: 448)!
    public static let bits512: BitcoinAddress.HashSize = BitcoinAddress.HashSize(sizeInBits: 512)!
}
