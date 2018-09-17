//
//  ScriptTests.swift
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

class ScriptTests: XCTestCase {
    func testScript() {
        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
        let toAddress = "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB" // https://testnet.coinfaucet.eu/en/

        let fromPublicKey = privateKey.publicKey()
        let fromPubKeyHash = Crypto.sha256ripemd160(fromPublicKey.data)
        let toPubKeyHash = Base58.decode(toAddress)!.dropFirst().dropLast(4)

        let lockingScript1 = Script.buildPublicKeyHashOut(pubKeyHash: fromPubKeyHash)
        let lockingScript2 = Script.buildPublicKeyHashOut(pubKeyHash: toPubKeyHash)

        XCTAssertEqual(Script.getPublicKeyHash(from: lockingScript1), fromPubKeyHash)
        XCTAssertEqual(Script.getPublicKeyHash(from: lockingScript2), toPubKeyHash)
    }

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
    
    func testCreate2of3MultisigScript() {
        let aliceKey = try! PrivateKey(wif: "cNaP9iG9DaNNemnVa2LXvw4rby5Xc4k6qydENQmLBm2aD7gD7GJi")
        let bobKey = try! PrivateKey(wif: "cSZEkc5cpjjmfK8E9MbTmHwmzck8MokK5Wd9LMTv59qdNSQNGBbG")
        let charlieKey = try! PrivateKey(wif: "cUJiRP3A2KoCVi7fwYBGTKUaiHKgvT9CSiXpoGJdbYP9kEqHKU4q")
        
        let redeemScript = Script(publicKeys: [aliceKey.publicKey(), bobKey.publicKey(), charlieKey.publicKey()], signaturesRequired: 2)
        XCTAssertNotNil(redeemScript)
        let p2shScript = redeemScript!.toP2SH()
        XCTAssertEqual(p2shScript.hex, "a914629a500c5eaac9261cac990c72241a959ff2d3d987")
        let multisigAddr = redeemScript!.standardP2SHAddress(network: Network.testnet)
        XCTAssertEqual(multisigAddr.cashaddr, "bchtest:pp3f55qvt64vjfsu4jvscu3yr22eluknmyt3nkwcx2", "multisig address should be the same as address created from bitcoin-ruby.")
    }
}
