//
//  DecodePointFromCompressedKeyTests.swift
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
@testable import BitcoinKit
import XCTest

class DecodePointTests: XCTestCase {
    func testPointDecoding() {
        do {
            let wifUncompressed = "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v"
            let wifCompresssed  = "L2r8WPXNgQ79rBdyxjdscd5HHr7BaD9P8Xov7NWZ9pVNw12TFSDZ"
            let privateKeyFromUncompressed = try PrivateKey(wif: wifUncompressed)
            let publicKeyUncompressed = privateKeyFromUncompressed.publicKey()
            XCTAssertFalse(publicKeyUncompressed.isCompressed)

            let decodedFromUncompressed: PointOnCurve = try PointOnCurve.decodePointFromPublicKey(publicKeyUncompressed)
            let expectedY = "ccfca71eff2101ad68238112e7585110e0f2c32d345225985356dc7cab8fdcc9"
            XCTAssertEqual(decodedFromUncompressed.y.data.hex, expectedY)

            let privateKeyFromCompressed = try PrivateKey(wif: wifCompresssed)
            let publicKeyCompressed = privateKeyFromCompressed.publicKey()
            XCTAssertTrue(publicKeyCompressed.isCompressed)

            let decodedFromCompressed: PointOnCurve = try PointOnCurve.decodePointFromPublicKey(publicKeyCompressed)
            XCTAssertEqual(decodedFromCompressed.y.data.hex, expectedY)
            XCTAssertEqual(decodedFromCompressed.y.data.hex, decodedFromUncompressed.y.data.hex)

        } catch {
            XCTFail("Error: \(error)")
        }
    }
}
