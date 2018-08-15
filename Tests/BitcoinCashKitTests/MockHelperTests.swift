//
//  MockHelperTests.swift
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

class MockHelperTests: XCTestCase {
    func testCustomMultisig() {
        // success with keyB
        succeedCustomMultisig(with: .keyB)
        // Fail with keyA, keyB, keyC
        failCustomMultisig(with: .keyA)
        failCustomMultisig(with: .keyC)
        failCustomMultisig(with: .keyD)
    }
    
    func verifyCustomMultisig(with key: MockKey) throws -> Bool {
        return try MockHelper.testScriptWithSingleKey(lockScript: customMultisigLockScript, unlockScriptBuilder: MultisigUnlockScriptBuilder(), hashType: SighashType.BCH.ALL, key: key)
    }
    
    func succeedCustomMultisig(with key: MockKey) {
        do {
            let result = try verifyCustomMultisig(with: key)
            XCTAssertTrue(result, "\(key) should be able to sign the multisig")
        } catch let error {
            XCTFail("\(key) should succeed, but ScriptMachine throw error: \(error)")
        }
    }
    
    func failCustomMultisig(with key: MockKey) {
        do {
            let result = try verifyCustomMultisig(with: key)
            XCTAssertFalse(result, "\(key) Should fail but succeeds.")
        } catch OpCodeExecutionError.error("OP_EQUALVERIFY failed.") {
            // Expected fail:  do nothing
        } catch let error {
            XCTFail("Inappropriate error for \(key) : \(error)")
        }
    }

    struct MultisigUnlockScriptBuilder: SingleKeyScriptBuilder {
        func build(with sigWithHashType: Data, key: MockKey) -> Script {
            return try! Script()
                .appendData(sigWithHashType)
                .appendData(key.pubkey.raw)
                .append(.OP_FALSE)
                .append(.OP_TRUE)
        }
    }
    
    var customMultisigLockScript: Script {
        let lockScript = try! Script()
            // stack: sig pub bool2 bool1
            .append(.OP_IF)
                .append(.OP_IF)
                    .append(.OP_DUP)
                    .append(.OP_HASH160)
                    .appendData(MockKey.keyA.pubkeyHash)
                .append(.OP_ELSE)
                    .append(.OP_DUP)
                    .append(.OP_HASH160)
                    .appendData(MockKey.keyB.pubkeyHash)
                .append(.OP_ENDIF)
            .append(.OP_ELSE)
                .append(.OP_IF)
                    .append(.OP_DUP)
                    .append(.OP_HASH160)
                    .appendData(MockKey.keyC.pubkeyHash)
                .append(.OP_ELSE)
                    .append(.OP_DUP)
                    .append(.OP_HASH160)
                    .appendData(MockKey.keyD.pubkeyHash)
                .append(.OP_ENDIF)
            .append(.OP_ENDIF)
            // stack: sig pub pubkeyhash pubkeyhash
            .append(.OP_EQUALVERIFY)
            // stack: sig pub
            .append(.OP_CHECKSIG)
        return lockScript
    }
}
