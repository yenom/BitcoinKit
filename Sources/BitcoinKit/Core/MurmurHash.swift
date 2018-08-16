//
//  MurMurHash.swift
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

public struct MurmurHash {
    private static func rotateLeft(_ x: UInt32, _ r: UInt32) -> UInt32 {
        return (x << r) | (x >> (32 - r))
    }

    public static func hashValue(_ bytes: Data, _ seed: UInt32) -> UInt32 {
        let c1: UInt32 = 0xcc9e2d51
        let c2: UInt32 = 0x1b873593

        let byteCount = bytes.count

        var h1 = seed
        for i in stride(from: 0, to: byteCount - 3, by: 4) {
            var k1 = UInt32(bytes[i])
            k1 |= UInt32(bytes[i + 1]) << 8
            k1 |= UInt32(bytes[i + 2]) << 16
            k1 |= UInt32(bytes[i + 3]) << 24

            k1 = k1 &* c1
            k1 = rotateLeft(k1, 15)
            k1 = k1 &* c2

            h1 = h1 ^ k1
            h1 = rotateLeft(h1, 13)
            h1 = h1 &* 5 &+ 0xe6546b64
        }
        let remaining = byteCount & 3
        if remaining != 0 {
            var k1 = UInt32(0)
            for r in 0 ..< remaining {
                k1 |= UInt32(bytes[byteCount - 1 - r]) << (8 * (remaining - 1 - r))
            }

            var k = k1 &* c1
            k = rotateLeft(k, 15)
            k = k &* c2

            h1 ^= k
        }

        h1 ^= UInt32(truncatingIfNeeded: byteCount)
        h1 ^= (h1 >> 16)
        h1 = h1 &* 0x85ebca6b
        h1 ^= (h1 >> 13)
        h1 = h1 &* 0xc2b2ae35
        h1 ^= (h1 >> 16)

        return h1
    }
}
