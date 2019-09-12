//
//  UInt32MathTests.swift
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

class UInt32MathTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func test1() {
		XCTAssertEqual(ceil_log2(0), 0)
		XCTAssertEqual(ceil_log2(1), 0)
		XCTAssertEqual(ceil_log2(2), 1)
		XCTAssertEqual(ceil_log2(3), 2)
		XCTAssertEqual(ceil_log2(4), 2)
		XCTAssertEqual(ceil_log2(5), 3)
		XCTAssertEqual(ceil_log2(6), 3)
		XCTAssertEqual(ceil_log2(7), 3)
		XCTAssertEqual(ceil_log2(8), 3)
		XCTAssertEqual(ceil_log2(9), 4)
		XCTAssertEqual(ceil_log2(10), 4)
		XCTAssertEqual(ceil_log2(11), 4)
		XCTAssertEqual(ceil_log2(12), 4)
		XCTAssertEqual(ceil_log2(13), 4)
		XCTAssertEqual(ceil_log2(14), 4)
		XCTAssertEqual(ceil_log2(15), 4)
		XCTAssertEqual(ceil_log2(16), 4)
		XCTAssertEqual(ceil_log2(17), 5)
		
		XCTAssertEqual(ceil_log2(UInt32.max-1), 32)
		XCTAssertEqual(ceil_log2(UInt32.max), 32)
	}
}
