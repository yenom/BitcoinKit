//
//  MockHelperTests.swift
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

class MockHelperTests: XCTestCase {
    // MARK: - Tests
    // multisig
    func testMultisig() {
        func verify(with key: MockKey) throws -> Bool {
            return try MockHelper.testScriptWithSingleKey(lockScript: multisigScript, unlockScriptBuilder: MultisigUnlockScriptBuilder(), hashType: SighashType.BCH.ALL, key: key)
        }
        
        func succeed(with key: MockKey) {
            do {
                let result = try verify(with: key)
                XCTAssertTrue(result, "P2SHMultisig: \(key) should be able to sign.")
            } catch let error {
                XCTFail("P2SHMultisig: \(key) should succeed, but ScriptMachine throw error: \(error)")
            }
        }
        
        func fail(with key: MockKey) {
            do {
                let result = try verify(with: key)
                XCTAssertFalse(result, "P2SHMultisig: \(key) Should fail but succeeds.")
            } catch ScriptMachineError.error("Last item on the stack is false.") {
                // Expected fail:  do nothing
            } catch let error {
                XCTFail("P2SHMultisig: Inappropriate error for \(key) : \(error)")
            }
        }
        
        
        // success with keyA, keyB, keyC
        succeed(with: .keyA)
        succeed(with: .keyB)
        succeed(with: .keyC)
        // Fail with keyD
        fail(with: .keyD)
    }

    // p2sh multisig
    func testP2SHMultisig() {
        func verify(with key: MockKey) throws -> Bool {
            return try MockHelper.testScriptWithSingleKey(lockScript: p2shMultisigLockScript, unlockScriptBuilder: P2SHMultisigUnlockScriptBuilder(), hashType: SighashType.BCH.ALL, key: key)
        }
        
        func succeed(with key: MockKey) {
            do {
                let result = try verify(with: key)
                XCTAssertTrue(result, "P2SHMultisig: \(key) should be able to sign.")
            } catch let error {
                XCTFail("P2SHMultisig: \(key) should succeed, but ScriptMachine throw error: \(error)")
            }
        }
        
        func fail(with key: MockKey) {
            do {
                let result = try verify(with: key)
                XCTAssertFalse(result, "P2SHMultisig: \(key) Should fail but succeeds.")
            } catch ScriptMachineError.error("Last item on the stack is false.") {
                // Expected fail:  do nothing
            } catch let error {
                XCTFail("P2SHMultisig: Inappropriate error for \(key) : \(error)")
            }
        }
        
        
        // success with keyA, keyB, keyC
        succeed(with: .keyA)
        succeed(with: .keyB)
        succeed(with: .keyC)
        // Fail with keyD
        fail(with: .keyD)
    }

    // custom multisig
    func testCustomMultisig() {
        func verify(with key: MockKey) throws -> Bool {
            return try MockHelper.testScriptWithSingleKey(lockScript: customMultisigLockScript, unlockScriptBuilder: CustomMultisigUnlockScriptBuilder(), hashType: SighashType.BCH.ALL, key: key)
        }
        
        func succeed(with key: MockKey) {
            do {
                let result = try verify(with: key)
                XCTAssertTrue(result, "CustomMultisig: \(key) should be able to sign.")
            } catch let error {
                XCTFail("CustomMultisig: \(key) should succeed, but ScriptMachine throw error: \(error)")
            }
        }
        
        func fail(with key: MockKey) {
            do {
                let result = try verify(with: key)
                XCTAssertFalse(result, "CustomMultisig: \(key) Should fail but succeeds.")
            } catch OpCodeExecutionError.error("OP_EQUALVERIFY failed.") {
                // Expected fail:  do nothing
            } catch let error {
                XCTFail("CustomMultisig: Inappropriate error for \(key) : \(error)")
            }
        }

        
        // success with keyA, keyB, keyC
        succeed(with: .keyA)
        succeed(with: .keyB)
        succeed(with: .keyC)
        // Fail with keyD
        fail(with: .keyD)
    }
    
    // MARK: - Unlock Script Builder
    // multisig unlock
    struct MultisigUnlockScriptBuilder: SingleKeyScriptBuilder {
        func build(with sigWithHashType: Data, key: MockKey) -> Script {
            return try! Script()
                .append(.OP_0)
                .appendData(sigWithHashType)
        }
    }
    
    // p2sh multisig unlock
    struct P2SHMultisigUnlockScriptBuilder: SingleKeyScriptBuilder {
        func build(with sigWithHashType: Data, key: MockKey) -> Script {
            let redeemScript = Script(publicKeys: [MockKey.keyA.pubkey, MockKey.keyB.pubkey, MockKey.keyC.pubkey], signaturesRequired: 1)!
            return try! Script()
                .append(.OP_0)
                .appendData(sigWithHashType)
                .appendData(redeemScript.data)
        }
    }
    
    // custom multisig unlock
    struct CustomMultisigUnlockScriptBuilder: SingleKeyScriptBuilder {
        func build(with sigWithHashType: Data, key: MockKey) -> Script {
            switch key {
            case .keyA:
                return try! Script()
                    .appendData(sigWithHashType)
                    .appendData(key.pubkey.raw)
                    .append(.OP_TRUE)
                    .append(.OP_TRUE)
            case .keyB:
                return try! Script()
                    .appendData(sigWithHashType)
                    .appendData(key.pubkey.raw)
                    .append(.OP_FALSE)
                    .append(.OP_TRUE)
            case .keyC:
                return try! Script()
                    .appendData(sigWithHashType)
                    .appendData(key.pubkey.raw)
                    .append(.OP_FALSE)
            default:
                // unlock script for keyA
                return try! Script()
                    .appendData(sigWithHashType)
                    .appendData(key.pubkey.raw)
                    .append(.OP_TRUE)
                    .append(.OP_TRUE)
            }
        }
    }
    
    // MARK: - Lock Script
    // multisig[ABC]
    let multisigScript = Script(publicKeys: [MockKey.keyA.pubkey, MockKey.keyB.pubkey, MockKey.keyC.pubkey], signaturesRequired: 1)!

    // P2SH multisig[ABC]
    var p2shMultisigLockScript: Script {
        return multisigScript.toP2SH()
    }
    
    // custom multisig[ABCD]
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
                .append(.OP_DUP)
                .append(.OP_HASH160)
                .appendData(MockKey.keyC.pubkeyHash)
            .append(.OP_ENDIF)
            // stack: sig pub pubkeyhash pubkeyhash
            .append(.OP_EQUALVERIFY)
            // stack: sig pub
            .append(.OP_CHECKSIG)
        return lockScript
    }
}
