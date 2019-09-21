//
//  PaymentURITests.swift
//
//  Copyright © 2018 Kishikawa Katsumi
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

class PaymentURITests: XCTestCase {
    func testPaymentURI() {
        let justAddress: PaymentURI
        do {
            justAddress = try PaymentURI("bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        } catch let e {
            XCTFail("PaymentURI error :\(e)")
            return
        }
        XCTAssertEqual(justAddress.address.network, .mainnetBTC)
        XCTAssertEqual(justAddress.address.legacy, "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertNil(justAddress.label)
        XCTAssertNil(justAddress.message)
        XCTAssertNil(justAddress.amount)
        XCTAssertTrue(justAddress.others.isEmpty)
        XCTAssertEqual(justAddress.uri, URL(string: "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu"))

        let addressWithName: PaymentURI
        do {
            addressWithName = try PaymentURI("bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?label=Luke-Jr")
        } catch let e {
            XCTFail("PaymentURI error :\(e)")
            return
        }

        XCTAssertEqual(addressWithName.address.network, .mainnetBTC)
        XCTAssertEqual(addressWithName.address.legacy, "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertEqual(addressWithName.label, "Luke-Jr")
        XCTAssertNil(addressWithName.message)
        XCTAssertNil(addressWithName.amount)
        XCTAssertTrue(addressWithName.others.isEmpty)
        XCTAssertEqual(addressWithName.uri, URL(string: "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?label=Luke-Jr"))

        let request20_30BTCToLukeJr: PaymentURI
        do {
            request20_30BTCToLukeJr = try PaymentURI("bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=20.3&label=Luke-Jr")
        } catch let e {
            XCTFail("PaymentURI error :\(e)")
            return
        }
        XCTAssertEqual(request20_30BTCToLukeJr.address.network, .mainnetBTC)
        XCTAssertEqual(request20_30BTCToLukeJr.address.legacy, "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertEqual(request20_30BTCToLukeJr.label, "Luke-Jr")
        XCTAssertEqual(request20_30BTCToLukeJr.amount, Decimal(string: "20.30"))
        XCTAssertNil(request20_30BTCToLukeJr.message)
        XCTAssertTrue(request20_30BTCToLukeJr.others.isEmpty)
        XCTAssertEqual(request20_30BTCToLukeJr.uri, URL(string: "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=20.3&label=Luke-Jr"))

        let request50BTCWithMessage: PaymentURI
        do {
            request50BTCWithMessage = try PaymentURI("bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz")
        } catch let e {
            XCTFail("PaymentURI error :\(e)")
            return
        }
        XCTAssertNotNil(request50BTCWithMessage)
        XCTAssertEqual(request50BTCWithMessage.address.network, .mainnetBTC)
        XCTAssertEqual(request50BTCWithMessage.address.legacy, "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertEqual(request50BTCWithMessage.label, "Luke-Jr")
        XCTAssertEqual(request50BTCWithMessage.amount, Decimal(string: "50"))
        XCTAssertEqual(request50BTCWithMessage.message, "Donation for project xyz")
        XCTAssertTrue(request50BTCWithMessage.others.isEmpty)
        XCTAssertEqual(request50BTCWithMessage.uri, URL(string: "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz"))

        do {
            _ = try PaymentURI("bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=abc&label=Luke-Jr")
            XCTFail("Should fail")
        } catch PaymentURIError.malformed(let key) {
            XCTAssertEqual(key, .amount)
        } catch {
            XCTFail("Unexpected error")
        }
    }
}
