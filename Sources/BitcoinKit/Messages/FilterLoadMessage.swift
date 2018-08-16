//
//  FilterLoadMessage.swift
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

public struct FilterLoadMessage {
    /// The filter itself is simply a bit field of arbitrary byte-aligned size. The maximum size is 36,000 bytes.
    public let filter: Data
    /// The number of hash functions to use in this filter. The maximum value allowed in this field is 50.
    public let nHashFuncs: UInt32
    /// A random value to add to the seed value in the hash function used by the bloom filter.
    public let nTweak: UInt32
    /// A set of flags that control how matched items are added to the filter.
    public let nFlags: UInt8

    public func serialized() -> Data {
        var data = Data()
        data += VarInt(filter.count).serialized()
        data += filter
        data += nHashFuncs
        data += nTweak
        data += nFlags
        return data
    }
}
