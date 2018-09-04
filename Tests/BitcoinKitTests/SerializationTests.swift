//
//  SerializationTests.swift
//
//  Copyright © 2018 pebble8888  All rights reserved.
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
    
    func test1() {
		let d = Data(bytes: [1, 2, 3, 4])
		let i: UInt32 = d.to(type: UInt32.self)
		XCTAssertEqual(i.hex, "04030201")
		XCTAssertEqual(i, 0x04030201)
	}
	
	func test2() {
		let d = Data(bytes: [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2])
		let i: UInt256 = d.to(type: UInt256.self)
		XCTAssertEqual(i.hex, "0200000000000000000000000000000000000000000000000000000000000001")
    }
    

}
