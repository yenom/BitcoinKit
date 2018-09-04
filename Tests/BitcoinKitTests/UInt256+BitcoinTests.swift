//
//  UInt256+BitcoinTests.swift
//
//  Copyright © 2018 pebble8888  All rights reserved.
//

import XCTest
@testable import BitcoinKit

class UInt256_BitcoinTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test1() {
		XCTAssertEqual(try UInt256(compact: UInt32(0x007fffff)).hex, "0000000000000000000000000000000000000000000000000000000000000000")
		XCTAssertEqual(try UInt256(compact: UInt32(0x017fffff)).hex, "000000000000000000000000000000000000000000000000000000000000007f")
		XCTAssertEqual(try UInt256(compact: UInt32(0x027fffff)).hex, "0000000000000000000000000000000000000000000000000000000000007fff")
		XCTAssertEqual(try UInt256(compact: UInt32(0x03123456)).hex, "0000000000000000000000000000000000000000000000000000000000123456")
		XCTAssertEqual(try UInt256(compact: UInt32(0x037fffff)).hex, "00000000000000000000000000000000000000000000000000000000007fffff")
		XCTAssertEqual(try UInt256(compact: UInt32(0x047fffff)).hex, "000000000000000000000000000000000000000000000000000000007fffff00")
		XCTAssertEqual(try UInt256(compact: UInt32(0x057fffff)).hex, "0000000000000000000000000000000000000000000000000000007fffff0000")
		XCTAssertEqual(try UInt256(compact: UInt32(0x067fffff)).hex, "00000000000000000000000000000000000000000000000000007fffff000000")
		XCTAssertEqual(try UInt256(compact: UInt32(0x077fffff)).hex, "000000000000000000000000000000000000000000000000007fffff00000000")
		XCTAssertEqual(try UInt256(compact: UInt32(0x087fffff)).hex, "0000000000000000000000000000000000000000000000007fffff0000000000")
		XCTAssertEqual(try UInt256(compact: UInt32(0x097fffff)).hex, "00000000000000000000000000000000000000000000007fffff000000000000")
		XCTAssertEqual(try UInt256(compact: UInt32(0x1d7fffff)).hex, "0000007fffff0000000000000000000000000000000000000000000000000000")
		XCTAssertEqual(try UInt256(compact: UInt32(0x1e7fffff)).hex, "00007fffff000000000000000000000000000000000000000000000000000000")
		XCTAssertEqual(try UInt256(compact: UInt32(0x1f7fffff)).hex, "007fffff00000000000000000000000000000000000000000000000000000000")
		XCTAssertEqual(try UInt256(compact: UInt32(0x207fffff)).hex, "7fffff0000000000000000000000000000000000000000000000000000000000")
		XCTAssertEqual(try UInt256(compact: UInt32(0x2100ffff)).hex, "ffff000000000000000000000000000000000000000000000000000000000000")
		XCTAssertEqual(try UInt256(compact: UInt32(0x220000ff)).hex, "ff00000000000000000000000000000000000000000000000000000000000000")
	}
	
	func testOverflow() {
		do {
			_ = try UInt256(compact: UInt32(0x21010000))
			XCTFail()
		} catch UInt256.CompactError.overflow {
		} catch {
			XCTFail()
		}
		
		do {
    		_ = try UInt256(compact: UInt32(0x22000100))
			XCTFail()
		} catch UInt256.CompactError.overflow {
		} catch {
			XCTFail()
		}
		
		do {
			_ = try UInt256(compact: UInt32(0x23000001))
			XCTFail()
    	} catch UInt256.CompactError.overflow {
    	} catch {
        	XCTFail()
    	}

		do {
			_ = try UInt256(compact: UInt32(0xff000001))
			XCTFail()
        } catch UInt256.CompactError.overflow {
        } catch {
        	XCTFail()
        }
    }
	
	// negative
	func testNegative() {
		do {
			_ = try UInt256(compact: UInt32(0x008fffff))
			XCTFail()
		} catch UInt256.CompactError.negative {
		} catch {
			XCTFail()
		}
		
		do {
			_ = try UInt256(compact: UInt32(0x009fffff))
			XCTFail()
		} catch UInt256.CompactError.negative {
		} catch {
			XCTFail()
		}
		
		do {
			_ = try UInt256(compact: UInt32(0x00ffffff))
			XCTFail()
		} catch UInt256.CompactError.negative {
		} catch {
			XCTFail()
		}
	}
}
