//
//  BloomFilter.swift
//
//  Copyright © 2018 Kishikawa Katsumi
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

public struct BloomFilter {
    public let nHashFuncs: UInt32
    public let nTweak: UInt32
    public let size: UInt32

    private var filter: [UInt8]
    var data: Data {
        return Data(filter)
    }

    let MAX_FILTER_SIZE: UInt32 = 36_000
    let MAX_HASH_FUNCS: UInt32 = 50

    public init(elements: Int, falsePositiveRate: Double, randomNonce nTweak: UInt32) {
        self.size = max(1, min(UInt32(-1.0 / pow(log(2), 2) * Double(elements) * log(falsePositiveRate)), MAX_FILTER_SIZE * 8) / 8)
        filter = [UInt8](repeating: 0, count: Int(size))
        self.nHashFuncs = max(1, min(UInt32(Double(size * UInt32(8)) / Double(elements) * log(2)), MAX_HASH_FUNCS))
        self.nTweak = nTweak
    }

    public mutating func insert(_ data: Data) {
        for i in 0..<nHashFuncs {
            let seed = i &* 0xFBA4C795 &+ nTweak
            let nIndex = Int(MurmurHash.hashValue(data, seed) % (size * 8))
            filter[nIndex >> 3] |= (1 << (7 & nIndex))
        }
    }
}

extension BloomFilter: CustomDebugStringConvertible {
    public var debugDescription: String {
        return filter.compactMap { bits(fromByte: $0).map { $0.description }.joined() }.joined()
    }

    enum Bit: UInt8, CustomStringConvertible {
        case zero, one

        var description: String {
            switch self {
            case .one: return "1"
            case .zero: return "0"
            }
        }
    }

    func bits(fromByte byte: UInt8) -> [Bit] {
        var byte = byte
        var bits = [Bit](repeating: .zero, count: 8)
        for i in 0..<8 {
            let currentBit = byte & 0x01
            if currentBit != 0 {
                bits[i] = .one
            }
            byte >>= 1
        }
        return bits
    }
}
