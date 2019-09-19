//
//  UInt256+BitcoinTests.swift
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

class UInt256_BitcoinTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test1() {
        // size = 0
		XCTAssertEqual(try UInt256(compact: 0x007fffff as UInt32).hex, "0000000000000000000000000000000000000000000000000000000000000000")
        // target -0
        XCTAssertEqual(try UInt256(compact: 0x22800000 as UInt32).hex, "0000000000000000000000000000000000000000000000000000000000000000")
        // target 0
        XCTAssertEqual(try UInt256(compact: 0x22000000 as UInt32).hex, "0000000000000000000000000000000000000000000000000000000000000000")
		XCTAssertEqual(try UInt256(compact: 0x017fffff as UInt32).hex, "000000000000000000000000000000000000000000000000000000000000007f")
		XCTAssertEqual(try UInt256(compact: 0x027fffff as UInt32).hex, "0000000000000000000000000000000000000000000000000000000000007fff")
		XCTAssertEqual(try UInt256(compact: 0x03123456 as UInt32).hex, "0000000000000000000000000000000000000000000000000000000000123456")
		XCTAssertEqual(try UInt256(compact: 0x037fffff as UInt32).hex, "00000000000000000000000000000000000000000000000000000000007fffff")
		XCTAssertEqual(try UInt256(compact: 0x047fffff as UInt32).hex, "000000000000000000000000000000000000000000000000000000007fffff00")
		XCTAssertEqual(try UInt256(compact: 0x057fffff as UInt32).hex, "0000000000000000000000000000000000000000000000000000007fffff0000")
		XCTAssertEqual(try UInt256(compact: 0x067fffff as UInt32).hex, "00000000000000000000000000000000000000000000000000007fffff000000")
		XCTAssertEqual(try UInt256(compact: 0x077fffff as UInt32).hex, "000000000000000000000000000000000000000000000000007fffff00000000")
		XCTAssertEqual(try UInt256(compact: 0x087fffff as UInt32).hex, "0000000000000000000000000000000000000000000000007fffff0000000000")
		XCTAssertEqual(try UInt256(compact: 0x097fffff as UInt32).hex, "00000000000000000000000000000000000000000000007fffff000000000000")
		XCTAssertEqual(try UInt256(compact: 0x1d7fffff as UInt32).hex, "0000007fffff0000000000000000000000000000000000000000000000000000")
		XCTAssertEqual(try UInt256(compact: 0x1e7fffff as UInt32).hex, "00007fffff000000000000000000000000000000000000000000000000000000")
		XCTAssertEqual(try UInt256(compact: 0x1f7fffff as UInt32).hex, "007fffff00000000000000000000000000000000000000000000000000000000")
		XCTAssertEqual(try UInt256(compact: 0x207fffff as UInt32).hex, "7fffff0000000000000000000000000000000000000000000000000000000000")
		XCTAssertEqual(try UInt256(compact: 0x2100ffff as UInt32).hex, "ffff000000000000000000000000000000000000000000000000000000000000")
		XCTAssertEqual(try UInt256(compact: 0x220000ff as UInt32).hex, "ff00000000000000000000000000000000000000000000000000000000000000")
	}
	
	func testOverflow() {
		do {
			_ = try UInt256(compact: 0x21010000 as UInt32)
			XCTFail()
		} catch UInt256.CompactError.overflow {
		} catch {
			XCTFail()
		}
		
		do {
    		_ = try UInt256(compact: 0x22000100 as UInt32)
			XCTFail()
		} catch UInt256.CompactError.overflow {
		} catch {
			XCTFail()
		}
		
		do {
			_ = try UInt256(compact: 0x23000001 as UInt32)
			XCTFail()
    	} catch UInt256.CompactError.overflow {
    	} catch {
        	XCTFail()
    	}

		do {
			_ = try UInt256(compact: 0xff000001 as UInt32)
			XCTFail()
        } catch UInt256.CompactError.overflow {
        } catch {
        	XCTFail()
        }
    }
	
	// negative
	func testNegative() {
		do {
			_ = try UInt256(compact: 0x108fffff as UInt32)
			XCTFail()
		} catch UInt256.CompactError.negative {
		} catch {
			XCTFail()
		}
		
		do {
			_ = try UInt256(compact: 0x109fffff as UInt32)
			XCTFail()
		} catch UInt256.CompactError.negative {
		} catch {
			XCTFail()
		}
		
		do {
			_ = try UInt256(compact: 0x10ffffff as UInt32)
			XCTFail()
		} catch UInt256.CompactError.negative {
		} catch {
			XCTFail()
		}
	}
}
