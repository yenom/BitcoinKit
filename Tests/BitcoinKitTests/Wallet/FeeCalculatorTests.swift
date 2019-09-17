//
//  FeeCalculatorTests.swift
//
//  Copyright © 2019 BitcoinKit developers
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

final class FeeCalculatorTests: XCTestCase {
    func testCalculateDust() {
        XCTAssertEqual(FeeCalculator.calculateDust(feePerByte: 1), 546)
        XCTAssertEqual(FeeCalculator.calculateDust(feePerByte: 2), 1092)
        XCTAssertEqual(FeeCalculator.calculateDust(feePerByte: 123), 67158)
    }
    
    func testCalculateSingleInputFee() {
        XCTAssertEqual(FeeCalculator.calculateSingleInputFee(feePerByte: 1), 148)
        XCTAssertEqual(FeeCalculator.calculateSingleInputFee(feePerByte: 2), 296)
        XCTAssertEqual(FeeCalculator.calculateSingleInputFee(feePerByte: 123), 18_204)
    }
    
    func testCalculateFee() {
        XCTAssertEqual(FeeCalculator.calculateFee(inputs: 0, outputs: 0, feePerByte: 1), 0)
        XCTAssertEqual(FeeCalculator.calculateFee(inputs: 1, outputs: 0, feePerByte: 1), 158)
        XCTAssertEqual(FeeCalculator.calculateFee(inputs: 0, outputs: 1, feePerByte: 1), 0)
        XCTAssertEqual(FeeCalculator.calculateFee(inputs: 1, outputs: 1, feePerByte: 1), 192)
        XCTAssertEqual(FeeCalculator.calculateFee(inputs: 1, outputs: 1, feePerByte: 1), 192)
        XCTAssertEqual(FeeCalculator.calculateFee(inputs: 1, outputs: 2, feePerByte: 1), 226)
        XCTAssertEqual(FeeCalculator.calculateFee(inputs: 2, outputs: 1, feePerByte: 1), 340)
        XCTAssertEqual(FeeCalculator.calculateFee(inputs: 2, outputs: 2, feePerByte: 1), 374)
        XCTAssertEqual(FeeCalculator.calculateFee(inputs: 3, outputs: 1, feePerByte: 1), 488)
        XCTAssertEqual(FeeCalculator.calculateFee(inputs: 3, outputs: 2, feePerByte: 1), 522)
        XCTAssertEqual(FeeCalculator.calculateFee(inputs: 10, outputs: 20, feePerByte: 1), 2170)
        XCTAssertEqual(FeeCalculator.calculateFee(inputs: 10, outputs: 2, feePerByte: 1), 1558)
        XCTAssertEqual(FeeCalculator.calculateFee(inputs: 10, outputs: 2, feePerByte: 123), 191_634)
    }
}

