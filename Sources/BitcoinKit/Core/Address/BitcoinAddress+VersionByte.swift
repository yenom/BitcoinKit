//
//  BitcoinAddress+VersionByte.swift
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

public extension BitcoinAddress {
    /// An object that represents the version byte of a cashaddr.
    ///
    /// The most signficant bit is reserved and must be 0. The 4 next bits indicate the type of address and the 3 least significant bits indicate the size of the hash.
    /// https://www.bitcoincash.org/spec/cashaddr.html
    struct VersionByte {
        /// Version byte raw value
        public let rawValue: UInt8
        /// Hash type (P2PKH or P2SH)
        public let hashType: HashType
        /// Hash Size
        public let hashSize: HashSize

        /// Creates a new VersionByte instance from type and size.
        ///
        /// - Parameters:
        ///   - hashType: The type of the hash
        ///   - hashSize: The size of the hash
        public init(_ hashType: HashType, _ hashSize: HashSize) {
            self.rawValue = hashType.rawValue + hashSize.rawValue
            self.hashType = hashType
            self.hashSize = hashSize
        }

        /// Creates a new VersionByte instance from a raw UInt8 byte value.
        ///
        /// - Parameters:
        ///   - rawValue: The actual version byte
        public init?(_ rawValue: UInt8) {
            // X------- (The first bit) is zero
            // -XXXX--- (Next four bits) are type bits
            // -----XXX (The least three bits) are size bits
            let firstBit: UInt8 = rawValue & 0b10000000
            let typeBits: UInt8 = rawValue & 0b01111000
            let sizeBits: UInt8 = rawValue & 0b00000111
            guard firstBit == 0 else {
                return nil
            }
            guard let hashType = HashType(rawValue: typeBits) else {
                return nil
            }
            guard let hashSize = HashSize(rawValue: sizeBits) else {
                return nil
            }
            self.rawValue = rawValue
            self.hashType = hashType
            self.hashSize = hashSize
        }
    }
}

extension BitcoinAddress.VersionByte: Equatable {
    // swiftlint:disable operator_whitespace
    public static func ==(lhs: BitcoinAddress.VersionByte, rhs: BitcoinAddress.VersionByte) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
