//
//  ScriptTests.swift
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

class ScriptTests: XCTestCase {
    
    func testBinarySerialization() {
        XCTAssertEqual(Script().data, Data(), "Default script should be empty.")
        XCTAssertEqual(Script(data: Data())!.data, Data(), "Empty script should be empty.")
    }
    
    func testStringSerialization() {
        let yrashkScript: Data = Data(hex: "52210391e4786b4c7637c160247ad6d5702d9bb2860cbb8130d59b0fd9808a0220d50f2102e191fcff2849099988fbe1592b6788707a61401058c09ef97363c9d96c43a0cf21027f10a51295e8e96d5957f3665168426249a006e548e48cbfa5882d2bf89ab67e2103d39801bafef0cc3c211101a54a47874c0a835efa2c17c47ebbe380c803345a2354ae")!
        let script = Script(data: yrashkScript)
        XCTAssertNotNil(script, "sanity check")
    }
    
    func testStandardScript() {
        let script = Script(data: Data(hex: "76a9147ab89f9fae3f8043dcee5f7b5467a0f0a6e2f7e188ac")!)!
        XCTAssertTrue(script.isPayToPublicKeyHashScript, "should be regular hash160 script")
        
        let address = try! AddressFactory.create("1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG")
        let script2 = Script(address: address)
        XCTAssertEqual(script2!.data, script.data, "script created from extracted address should be the same as the original script")
        XCTAssertEqual(script2!.string, script.string, "script created from extracted address should be the same as the original script")
    }
}
