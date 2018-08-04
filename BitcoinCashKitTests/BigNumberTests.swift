//
//  BigNumberTests.swift
//
//  Copyright © 2018 BitcoinCashKit developers
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
@testable import BitcoinCashKit

class BigNumberTests: XCTestCase {
    func testBigNumber() {
        XCTAssertEqual(BigNumber(), BigNumber.zero, "default bignum should be zero")
        XCTAssertNotEqual(BigNumber(), BigNumber.one, "default bignum should not be one")
//        XCTAssertEqual("0", BigNumber().string(inBase: 10), "default bignum should be zero")
//        XCTAssertEqual(BigNumber(0), BigNumber.zero, "0 should be equal to itself")
//
//        XCTAssertEqual(BigNumber.one, BigNumber.one, "1 should be equal to itself")
//        XCTAssertEqual(BigNumber.one, BigNumber(1), "1 should be equal to itself")
//
//        XCTAssertEqual(BigNumber.one.string(inBase: 16), "1", "1 should be correctly printed out")
//        XCTAssertEqual(BigNumber(1).string(inBase: 16), "1", "1 should be correctly printed out")
//        XCTAssertEqual(BigNumber(0xdeadf00d).string(inBase: 16), "deadf00d", "0xdeadf00d should be correctly printed out")
//
//        XCTAssertEqual(BigNumber(uint64: 0xdeadf00ddeadf00d).string(inBase: 16), "deadf00ddeadf00d", "0xdeadf00ddeadf00d should be correctly printed out")
//
//        XCTAssertEqual(BigNumber(string: "0b1010111", base: 2).string(inBase: 2), "1010111", "0b1010111 should be correctly parsed")
//        XCTAssertEqual(BigNumber(string: "0x12346789abcdef", base: 16).string(inBase: 16), "12346789abcdef", "0x12346789abcdef should be correctly parsed")
//
//
//        do {
//            let bn = BigNumber(uint64: 0xdeadf00ddeadbeef)!
//            let data = bn.signedLittleEndian
//            XCTAssertEqual("efbeadde0df0adde00", data!.hex, "littleEndianData should be little-endian with trailing zero byte")
//            let bn2 = BigNumber(signedLittleEndian: data)!
//            XCTAssertEqual("deadf00ddeadbeef", bn2.hexString, "converting to and from data should give the same result")
//        }

    }

//    func testNegativeZero() {
//
//        let zeroBN: BigNumber = BigNumber.zero
//        let negativeZeroBN = BigNumber(signedLittleEndian: Data(hex: "80")!)!
//        let zeroWithEmptyDataBN = BigNumber(signedLittleEndian: Data())!
//
//        //        print("negativeZeroBN.data = \(negativeZeroBN.data)") //-data is deprecated
//
//        XCTAssertNotNil(zeroBN, "must exist")
//        XCTAssertNotNil(negativeZeroBN, "must exist")
//        XCTAssertNotNil(zeroWithEmptyDataBN, "must exist")
//
//        //        print("negative zero: %lld", negativeZeroBN.int64value)
//
//        XCTAssertEqual(zeroBN.copy()!.add(BigNumber(int32: 1)), BigNumber.one(), "0 + 1 == 1")
//        XCTAssertEqual(negativeZeroBN.copy()!.add(BigNumber(int32: 1)), BigNumber.one(), "0 + 1 == 1")
//        XCTAssertEqual(zeroWithEmptyDataBN.copy()!.add(BigNumber(int32: 1)), BigNumber.one(), "0 + 1 == 1")
//s
//        // In BitcoinQT script.cpp, there is check (bn != bnZero).
//        // It covers negative zero alright because "bn" is created in a way that discards the sign.
//        XCTAssertNotEqual(zeroBN, negativeZeroBN, "zero should != negative zero")
//        XCTAssertFalse(_BIGNUM)
//
//    }

//    func testExperiments() {
//
//        do {
//            //let bn = BigNumber.zero()
//            let bn = BigNumber(unsignedBigEndian: Data(hex: "00")!)
//            print("bn = %@ %@ (%@) 0x%@ b36:%@", bn, bn.unsignedBigEndian, bn.decimalString, bn.stringInBase(16), bn.stringInBase(36))
//        }
//
//        do {
//            //let bn = BigNumber.one()
//            let bn = BigNumber(unsignedBigEndian: Data(hex: "01")!)
//            print("bn = %@ %@ (%@) 0x%@ b36:%@", bn, bn.unsignedBigEndian, bn.decimalString, bn.stringInBase(16), bn.stringInBase(36))
//        }
//
//        do {
//            let bn = BigNumber(UInt32: 0xdeadf00d)
//            print("bn = %@ (%@) 0x%@ b36:%@", bn, bn.decimalString, bn.stringInBase(16), bn.stringInBase(36))
//        }
//
//        do {
//            let bn = BigNumber(int32: -16)
//            print("bn = %@ (%@) 0x%@ b36:%@", bn, bn.decimalString, bn.stringInBase(16), bn.stringInBase(36))
//        }
//
//        do {
//            let base: UInt = 17
//            let bn = BigNumber(string: "123", base: base)
//            print("bn = %@", bn.stringInBase(base))
//        }
//
//        do {
//            let base: UInt = 12
//            let bn = BigNumber(string: "0b123", base: base)
//            print("bn = %@", bn.stringInBase(base))
//        }
//
//        do {
//            let bn = BigNumber(UInt64: 0xdeadf00ddeadbeef)
//            let data = bn.signedLittleEndian
//            let bn2 = BigNumber(signedLittleEndian: data)
//            print("bn = %@", bn2.hexString)
//        }
//    }
}
