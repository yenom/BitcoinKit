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
            // do nothing
            // print("ScriptMachine throw error: \(error)")
        } catch let error {
            XCTFail("Inappropriate error for \(key) : \(error)")
        }
    }

    struct MultisigUnlockScriptBuilder: SingleKeyScriptBuilder {
        func build(with sigWithHashType: Data, key: MockKey) -> Script {
            let unlockScript: Script = Script()
            try! unlockScript.appendData(sigWithHashType)
            try! unlockScript.appendData(key.pubkey.raw)
            try! unlockScript.append(.OP_FALSE)
            try! unlockScript.append(.OP_TRUE)
            return unlockScript
        }
    }
    
    var customMultisigLockScript: Script {
        let lockScript = Script()
        // stack: sig pub bool2 bool1
        try! lockScript.append(.OP_IF)
            try! lockScript.append(.OP_IF)
                try! lockScript.append(.OP_DUP)
                try! lockScript.append(.OP_HASH160)
                try! lockScript.appendData(MockKey.keyA.pubkeyHash)
            try! lockScript.append(.OP_ELSE)
                try! lockScript.append(.OP_DUP)
                try! lockScript.append(.OP_HASH160)
                try! lockScript.appendData(MockKey.keyB.pubkeyHash)
            try! lockScript.append(.OP_ENDIF)
        try! lockScript.append(.OP_ELSE)
            try! lockScript.append(.OP_IF)
                try! lockScript.append(.OP_DUP)
                try! lockScript.append(.OP_HASH160)
                try! lockScript.appendData(MockKey.keyC.pubkeyHash)
            try! lockScript.append(.OP_ELSE)
                try! lockScript.append(.OP_DUP)
                try! lockScript.append(.OP_HASH160)
                try! lockScript.appendData(MockKey.keyD.pubkeyHash)
            try! lockScript.append(.OP_ENDIF)
        try! lockScript.append(.OP_ENDIF)
        
        // stack: sig pub pubkeyhash pubkeyhash
        try! lockScript.append(.OP_EQUALVERIFY)
        // stack: sig pub
        try! lockScript.append(.OP_CHECKSIG)
        return lockScript
    }
}
