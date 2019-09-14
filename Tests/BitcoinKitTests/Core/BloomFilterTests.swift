//
//  BloomFilterTests.swift
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

import XCTest
@testable import BitcoinKit

class BloomFilterTests: XCTestCase {
    func testBloomFilter() {
        do {
            var filter = BloomFilter(elements: 1, falsePositiveRate: 0.0001, randomNonce: 0)
            filter.insert(Data(hex: "019f5b01d4195ecbc9398fbf3c3b1fa9bb3183301d7a1fb3bd174fcfa40a2b65")!)
            XCTAssertEqual(filter.data.hex, "b50f")
        }
        do {
            var filter = BloomFilter(elements: 3, falsePositiveRate: 0.01, randomNonce: 0)
            filter.insert(Data(hex: "99108ad8ed9bb6274d3980bab5a85c048f0950c8")!)
            filter.insert(Data(hex: "b5a2c786d9ef4658287ced5914b37a1b4aa32eee")!)
            filter.insert(Data(hex: "b9300670b4c5366e95b2699e8b18bc75e5f729c5")!)

            let message = FilterLoadMessage(filter: Data(filter.data), nHashFuncs: filter.nHashFuncs, nTweak: filter.nTweak, nFlags: 1)
            XCTAssertEqual(message.serialized().hex, Data(hex: "03614e9b050000000000000001")!.hex)
        }
        do {
            var filter = BloomFilter(elements: 3, falsePositiveRate: 0.01, randomNonce: 2147483649)
            filter.insert(Data(hex: "99108ad8ed9bb6274d3980bab5a85c048f0950c8")!)
            filter.insert(Data(hex: "b5a2c786d9ef4658287ced5914b37a1b4aa32eee")!)
            filter.insert(Data(hex: "b9300670b4c5366e95b2699e8b18bc75e5f729c5")!)

            let message = FilterLoadMessage(filter: Data(filter.data), nHashFuncs: filter.nHashFuncs, nTweak: filter.nTweak, nFlags: 1)
            XCTAssertEqual(message.serialized().hex, Data(hex: "03ce4299050000000100008001")!.hex)
        }
        do {
            var filter = BloomFilter(elements: 4, falsePositiveRate: 0.001, randomNonce: 100)
            filter.insert(Data(hex: "03cdb817b334c8e3bdc6ce3a1eae9e624cc64426eb00ef9207d2021ce6d9253a2a")!)
            filter.insert(Data(hex: "a9a917faa1751b127c55e7e19f59f2e57627e908")!)
            filter.insert(Data(hex: "02784addc6ceed8bbbee10829194ce17c99a6a7029b3a9e078b6f849aa91c937b5")!)
            filter.insert(Data(hex: "7a501a08279ec396e06c88b3e9013f31c0d4ca76")!)

            let message = FilterLoadMessage(filter: Data(filter.data), nHashFuncs: filter.nHashFuncs, nTweak: filter.nTweak, nFlags: 1)
            XCTAssertEqual(message.serialized().hex, Data(hex: "07cfe07884ebc3ac090000006400000001")!.hex)
        }
        do {
            var filter = BloomFilter(elements: 4, falsePositiveRate: 0.001, randomNonce: 100)

            let publicKey1 = PublicKey(bytes: Data(hex: "03cdb817b334c8e3bdc6ce3a1eae9e624cc64426eb00ef9207d2021ce6d9253a2a")!, network: .testnet)
            filter.insert(publicKey1.data)
            filter.insert(Crypto.sha256ripemd160(publicKey1.data))

            let publicKey2 = PublicKey(bytes: Data(hex: "02784addc6ceed8bbbee10829194ce17c99a6a7029b3a9e078b6f849aa91c937b5")!, network: .testnet)
            filter.insert(publicKey2.data)
            filter.insert(Crypto.sha256ripemd160(publicKey2.data))

            let message = FilterLoadMessage(filter: Data(filter.data), nHashFuncs: filter.nHashFuncs, nTweak: filter.nTweak, nFlags: 1)
            XCTAssertEqual(message.serialized().hex, Data(hex: "07cfe07884ebc3ac090000006400000001")!.hex)
        }
    }
}
