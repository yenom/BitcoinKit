//
//  SerializationTests.swift
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

import XCTest
@testable import BitcoinKit

class SerializationTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUInt32toHex() {
		let d = Data([1, 2, 3, 4])
		let i: UInt32 = d.to(type: UInt32.self)
		XCTAssertEqual(i.hex, "04030201")
		XCTAssertEqual(i, 0x04030201)
	}

    func testUInt64toHex() {
        let d = Data([1, 2, 3, 4, 5, 6, 7, 8])
        let i: UInt64 = d.to(type: UInt64.self)
        XCTAssertEqual(i.hex, "0807060504030201")
        XCTAssertEqual(i, 0x0807060504030201)
    }

	func testDataToUInt256() {
		let d = Data([1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2])
		let i: UInt256 = d.to(type: UInt256.self)
		XCTAssertEqual(i.hex, "0200000000000000000000000000000000000000000000000000000000000001")
    }

    func testDataToInt32() {
        for _ in 0..<10 {
            for i in 0...255 {
                let data: Data = Data([UInt8(i)])
                let intValue: Int32 = data.to(type: Int32.self)
                XCTAssertEqual(intValue, Int32(i), "\(i) time")
            }
        }
    }
}
