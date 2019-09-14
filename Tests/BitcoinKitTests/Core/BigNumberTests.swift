//
//  BigNumberTests.swift
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

class BigNumberTests: XCTestCase {
    func testBigNumber() {
        XCTAssertEqual(BigNumber(), BigNumber.zero, "default bignum should be zero")
        XCTAssertNotEqual(BigNumber(), BigNumber.one, "default bignum should not be one")

        XCTAssertEqual(BigNumber(1).data.hex, "01", "Init")
        XCTAssertEqual(BigNumber(2).data.hex, "02", "Init")
        XCTAssertEqual(BigNumber(4).data.hex, "04", "Init")
        XCTAssertEqual(BigNumber(8).data.hex, "08", "Init")
        XCTAssertEqual(BigNumber(16).data.hex, "10", "Init")
        XCTAssertEqual(BigNumber(32).data.hex, "20", "Init")
        XCTAssertEqual(BigNumber(64).data.hex, "40", "Init")
        XCTAssertEqual(BigNumber(127).data.hex, "7f", "Init")
        XCTAssertEqual(BigNumber(128).data.hex, "8000", "Init")
        XCTAssertEqual(BigNumber(129).data.hex, "8100", "Init")
        XCTAssertEqual(BigNumber(0x0100).data.hex, "0001", "Init")
        XCTAssertEqual(BigNumber(0x0200).data.hex, "0002", "Init")
        XCTAssertEqual(BigNumber(0x0400).data.hex, "0004", "Init")
        XCTAssertEqual(BigNumber(0x0800).data.hex, "0008", "Init")
        XCTAssertEqual(BigNumber(0x1000).data.hex, "0010", "Init")
        XCTAssertEqual(BigNumber(0x2000).data.hex, "0020", "Init")
        XCTAssertEqual(BigNumber(0x4000).data.hex, "0040", "Init")
        XCTAssertEqual(BigNumber(0x8000).data.hex, "008000", "Init")
        XCTAssertEqual(BigNumber(0x8001).data.hex, "018000", "Init")
        XCTAssertEqual(BigNumber(0x010000).data.hex, "000001", "Init")
        XCTAssertEqual(BigNumber(0x020000).data.hex, "000002", "Init")
        XCTAssertEqual(BigNumber(0x040000).data.hex, "000004", "Init")
        XCTAssertEqual(BigNumber(0x080000).data.hex, "000008", "Init")
        XCTAssertEqual(BigNumber(0x100000).data.hex, "000010", "Init")
        XCTAssertEqual(BigNumber(0x200000).data.hex, "000020", "Init")
        XCTAssertEqual(BigNumber(0x400000).data.hex, "000040", "Init")
        XCTAssertEqual(BigNumber(0x800000).data.hex, "00008000", "Init")
        XCTAssertEqual(BigNumber(0x01000000).data.hex, "00000001", "Init")
        XCTAssertEqual(BigNumber(0x02000000).data.hex, "00000002", "Init")
        XCTAssertEqual(BigNumber(0x04000000).data.hex, "00000004", "Init")
        XCTAssertEqual(BigNumber(0x08000000).data.hex, "00000008", "Init")
        XCTAssertEqual(BigNumber(0x10000000).data.hex, "00000010", "Init")
        XCTAssertEqual(BigNumber(0x20000000).data.hex, "00000020", "Init")
        XCTAssertEqual(BigNumber(0x40000000).data.hex, "00000040", "Init")

        
        XCTAssertEqual(BigNumber(-1).data.hex, "81", "Init")
        XCTAssertEqual(BigNumber(-2).data.hex, "82", "Init")
        XCTAssertEqual(BigNumber(-4).data.hex, "84", "Init")
        XCTAssertEqual(BigNumber(-8).data.hex, "88", "Init")
        XCTAssertEqual(BigNumber(-16).data.hex, "90", "Init")
        XCTAssertEqual(BigNumber(-32).data.hex, "a0", "Init")
        XCTAssertEqual(BigNumber(-64).data.hex, "c0", "Init")
        XCTAssertEqual(BigNumber(-127).data.hex, "ff", "Init")
        XCTAssertEqual(BigNumber(-128).data.hex, "8080", "Init")
        XCTAssertEqual(BigNumber(-129).data.hex, "8180", "Init")
        XCTAssertEqual(BigNumber(-0x0100).data.hex, "0081", "Init")
        XCTAssertEqual(BigNumber(-0x0200).data.hex, "0082", "Init")
        XCTAssertEqual(BigNumber(-0x0400).data.hex, "0084", "Init")
        XCTAssertEqual(BigNumber(-0x0800).data.hex, "0088", "Init")
        XCTAssertEqual(BigNumber(-0x1000).data.hex, "0090", "Init")
        XCTAssertEqual(BigNumber(-0x2000).data.hex, "00a0", "Init")
        XCTAssertEqual(BigNumber(-0x4000).data.hex, "00c0", "Init")
        XCTAssertEqual(BigNumber(-0x8000).data.hex, "008080", "Init")
        XCTAssertEqual(BigNumber(-0x8001).data.hex, "018080", "Init")
        XCTAssertEqual(BigNumber(-0x010000).data.hex, "000081", "Init")
        XCTAssertEqual(BigNumber(-0x020000).data.hex, "000082", "Init")
        XCTAssertEqual(BigNumber(-0x040000).data.hex, "000084", "Init")
        XCTAssertEqual(BigNumber(-0x080000).data.hex, "000088", "Init")
        XCTAssertEqual(BigNumber(-0x100000).data.hex, "000090", "Init")
        XCTAssertEqual(BigNumber(-0x200000).data.hex, "0000a0", "Init")
        XCTAssertEqual(BigNumber(-0x400000).data.hex, "0000c0", "Init")
        XCTAssertEqual(BigNumber(-0x800000).data.hex, "00008080", "Init")
        XCTAssertEqual(BigNumber(-0x01000000).data.hex, "00000081", "Init")
        XCTAssertEqual(BigNumber(-0x02000000).data.hex, "00000082", "Init")
        XCTAssertEqual(BigNumber(-0x04000000).data.hex, "00000084", "Init")
        XCTAssertEqual(BigNumber(-0x08000000).data.hex, "00000088", "Init")
        XCTAssertEqual(BigNumber(-0x10000000).data.hex, "00000090", "Init")
        XCTAssertEqual(BigNumber(-0x20000000).data.hex, "000000a0", "Init")
        XCTAssertEqual(BigNumber(-0x40000000).data.hex, "000000c0", "Init")
    }

}
