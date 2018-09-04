//
//  UInt32+MathTests.swift
//
//  Copyright © 2018 pebble8888  All rights reserved.
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
