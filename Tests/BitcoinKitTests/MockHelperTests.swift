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
    // MARK: - 1 of 3 Multi-Sig [ABC]
    // MARK: Standard Multi-Sig
    struct Standard1of3 {
        static let lockScript: Script = Script(publicKeys: [MockKey.keyA.pubkey,
                                                     MockKey.keyB.pubkey,
                                                     MockKey.keyC.pubkey],
                                        signaturesRequired: 1)!
        
        struct UnlockScriptBuilder: MockUnlockScriptBuilder {
            func build(pairs: [SigKeyPair]) -> Script {
                guard let signature = pairs.first?.signature else {
                    return Script()
                }

                let script = try! Script()
                    .append(.OP_0)
                    .appendData(signature)
                return script
            }
        }
    }
    
    
    func testStandard() {
        func verify(with key: MockKey) throws -> Bool {
            return try MockHelper.verifySingleKey(
                lockScript: Standard1of3.lockScript,
                unlockScriptBuilder: Standard1of3.UnlockScriptBuilder(),
                key: key,
                verbose: false)
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
            } catch {
                // Expected fail:  do nothing
            }
        }
        
        
        // success with keyA, keyB, keyC
        succeed(with: .keyA)
        succeed(with: .keyB)
        succeed(with: .keyC)
        // Fail with keyD
        fail(with: .keyD)
    }

    // P2SH Multi-Sig
    struct P2SH1of3 {
        static let redeemScript: Script = Script(publicKeys: [MockKey.keyA.pubkey, MockKey.keyB.pubkey, MockKey.keyC.pubkey], signaturesRequired: 1)!
        
        static let lockScript: Script = redeemScript.toP2SH()
        
        struct UnlockScriptBuilder: MockUnlockScriptBuilder {
            func build(pairs: [SigKeyPair]) -> Script {
                guard let signature = pairs.first?.signature else {
                    return Script()
                }

                return try! Script()
                    .append(.OP_0)
                    .appendData(signature)
                    .appendData(redeemScript.data)
            }
        }
    }

    func testP2SH() {
        func verify(with key: MockKey) throws -> Bool {
            return try MockHelper.verifySingleKey(
                lockScript: P2SH1of3.lockScript,
                unlockScriptBuilder: P2SH1of3.UnlockScriptBuilder(),
                key: key,
                verbose: false)
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
            } catch {
                // Expected fail:  do nothing
            }
        }
        
        
        // success with keyA, keyB, keyC
        succeed(with: .keyA)
        succeed(with: .keyB)
        succeed(with: .keyC)
        // Fail with keyD
        fail(with: .keyD)
    }

    // Custom Multi-Sig
    struct Custom1of3 {
        static let lockScript = try! Script()
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
        
        struct UnlockScriptBuilder: MockUnlockScriptBuilder {
            func build(pairs: [SigKeyPair]) -> Script {
                guard let key = pairs.first?.key, let signature = pairs.first?.signature else {
                    return Script()
                }
                
                switch key {
                case MockKey.keyA.privkey.publicKey():
                    return try! Script()
                        .appendData(signature)
                        .appendData(key.data)
                        .append(.OP_TRUE)
                        .append(.OP_TRUE)
                case MockKey.keyB.privkey.publicKey():
                    return try! Script()
                        .appendData(signature)
                        .appendData(key.data)
                        .append(.OP_FALSE)
                        .append(.OP_TRUE)
                case MockKey.keyC.privkey.publicKey():
                    return try! Script()
                        .appendData(signature)
                        .appendData(key.data)
                        .append(.OP_FALSE)
                default:
                    // unlock script for keyA
                    return try! Script()
                        .appendData(signature)
                        .appendData(key.data)
                        .append(.OP_TRUE)
                        .append(.OP_TRUE)
                }
            }
        }

    }
    func testCustom() {
        func verify(with key: MockKey) throws -> Bool {
            return try MockHelper.verifySingleKey(
                lockScript: Custom1of3.lockScript,
                unlockScriptBuilder: Custom1of3.UnlockScriptBuilder(),
                key: key,
                verbose: false)
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
            } catch {
                // Expected fail:  do nothing
            }
        }

        
        // success with keyA, keyB, keyC
        succeed(with: .keyA)
        succeed(with: .keyB)
        succeed(with: .keyC)
        // Fail with keyD
        fail(with: .keyD)
    }
    
    // MARK: - 2 of 3 Multi-Sig [ABC]
    // Standard Multi-Sig
    struct Standard2of3 {
        static let lockScript = Script(publicKeys: [MockKey.keyA.pubkey,
                                                    MockKey.keyB.pubkey,
                                                    MockKey.keyC.pubkey],
                                       signaturesRequired: 2)!
        struct UnlockScriptBuilder: MockUnlockScriptBuilder {
            func build(pairs: [SigKeyPair]) -> Script {
                let script = try! Script().append(.OP_0)
                pairs.forEach { try! script.appendData($0.signature) }
                return script

            }
        }
    }
    func testStandard2of3() {
        func verify(with keys: [MockKey]) throws -> Bool {
            return try MockHelper.verifyMultiKey(
                lockScript: Standard2of3.lockScript,
                unlockScriptBuilder: Standard2of3.UnlockScriptBuilder(),
                keys: keys,
                verbose: false)
        }
        
        func succeed(with keys: [MockKey]) {
            do {
                let result = try verify(with: keys)
                XCTAssertTrue(result, "P2SHMultisig: \(keys) should be able to sign.")
            } catch let error {
                XCTFail("P2SHMultisig: \(keys) should succeed, but ScriptMachine throw error: \(error)")
            }
        }
        
        func fail(with keys: [MockKey]) {
            do {
                let result = try verify(with: keys)
                XCTAssertFalse(result, "P2SHMultisig: \(keys) Should fail but succeeds.")
            } catch {
                // Expected fail:  do nothing
            }
        }
        
        
        // success with AB, AC, BC
        succeed(with: [.keyA, .keyB])
        succeed(with: [.keyA, .keyC])
        succeed(with: [.keyB, .keyC])
        // Fail with AD, BD, CD
        fail(with: [.keyA, .keyD])
        fail(with: [.keyB, .keyD])
        fail(with: [.keyC, .keyD])
    }

}
