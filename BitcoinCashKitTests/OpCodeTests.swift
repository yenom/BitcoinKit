//
//  OpCodeTests.swift
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

class OpCodeTests: XCTestCase {
    var context: ScriptExecutionContext!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        context = ScriptExecutionContext()
        context.verbose = true
    }
    
    func testOp1Negate() {
        let opcode = OpCode.OP_1NEGATE
        do {
            try opcode.execute(context)
            let num = try context.number(at: -1)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(num, -1)
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
     // OP_N is not working correctly right now because we didn't implemente bignum
     // After implementing bignum, testOpN() should be enabled
     
    func testOpN() {
        let vectors: [(OpCodeProtocol, Int32)] = [(OpCode.OP_1NEGATE, -1),
                                               (OpCode.OP_1,1),
                                               (OpCode.OP_2,2),
                                               (OpCode.OP_3,3),
                                               (OpCode.OP_4,4),
                                               (OpCode.OP_5,5),
                                               (OpCode.OP_6,6),
                                               (OpCode.OP_7,7),
                                               (OpCode.OP_8,8),
                                               (OpCode.OP_9,9),
                                               (OpCode.OP_10,10),
                                               (OpCode.OP_11,11),
                                               (OpCode.OP_12,12),
                                               (OpCode.OP_13,13),
                                               (OpCode.OP_14,14),
                                               (OpCode.OP_15,15),
                                               (OpCode.OP_16,16)]

        for (i, (opcode, expectedNumber)) in vectors.enumerated() {
            do {
                try opcode.execute(context)
                let num = try context.number(at: -1)
                XCTAssertEqual(num, expectedNumber, "\(opcode.name)(\(opcode.value) execution test.")
                XCTAssertEqual(context.stack.count, i + 1)
            } catch let error {
                fail(with: opcode, error: error)
            }
        }
    }
 
    func testOpVerify() {
        pushRandomDataOnStack(context)
        let stackCountAtFirst: Int = context.stack.count
        let opcode = OpCode.OP_VERIFY
        
        // OP_CODE basic specification
        XCTAssertEqual(opcode.name, "OP_VERIFY")
        XCTAssertEqual(opcode.value, 0x69)

        // OP_VERIFY success
        do {
            context.pushToStack(true)
            XCTAssertEqual(context.stack.count, stackCountAtFirst + 1)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, stackCountAtFirst, "\(opcode.name)(\(String(format: "%02x", opcode.value)) execution test.")
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // OP_VERIFY fail
        do {
            context.pushToStack(false)
            try opcode.execute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error.")
        } catch OpCodeExecutionError.error("OP_VERIFY failed.") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"OP_VERIFY failed.\"), but threw \(error)")
        }
    }
    
    func testOpDuplicate() {
        pushRandomDataOnStack(context)
        let stackCountAtFirst: Int = context.stack.count
        let opcode = OpCode.OP_DUP
        // OP_CODE basic specification
        XCTAssertEqual(opcode.name, "OP_DUP")
        XCTAssertEqual(opcode.value, 0x76)

        // OP_DUP success
        do {
            // Stack has more than 1 item
            XCTAssertGreaterThanOrEqual(context.stack.count, 1)
            let stackSnapShot: [Data] = context.stack
            let dataOnTop: Data = context.stack.last!
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, stackCountAtFirst + 1, "\(opcode.name)(\(String(format: "%02x", opcode.value)) test: One data should be added to stack.")
            XCTAssertEqual(context.stack.dropLast().map { Data($0) }, stackSnapShot, "\(opcode.name)(\(String(format: "%02x", opcode.value)) test: The data except the top should be the same after the execution.")
            XCTAssertEqual(context.stack.last!, dataOnTop, "\(opcode.name)(\(String(format: "%02x", opcode.value)) test: The data on top should be copied and pushed.")
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // OP_DUP fail
        do {
            context.resetStack()
            XCTAssertEqual(context.stack.count, 0)
            try opcode.execute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error when stack is empty.")
        } catch OpCodeExecutionError.opcodeRequiresItemsOnStack(1) {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .opcodeRequiresItemsOnStack(1), but threw \(error)")
        }
    }
    
    func testOpEqualVerify() {
        let opcode = OpCode.OP_EQUALVERIFY
        // OP_EQUALVERIFY success
        do {
            try context.pushToStack(1)
            try context.pushToStack(1)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 0)
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // OP_EQUALVERIFY fail
        do {
            context.resetStack()
            try context.pushToStack(1)
            try context.pushToStack(3)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
        } catch OpCodeExecutionError.error("OP_CHECKSIGVERIFY failed.") {
            // success
            XCTAssertEqual(context.stack.count, 1)
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
    func testOpEqual() {
        let opcode = OpEqual()
        
        // OP_EQUAL success
        do {
            try context.pushToStack(1)
            try context.pushToStack(1)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.bool(at: -1), true)
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // OP_EQUAL fail
        context.resetStack()
        do {
            try context.pushToStack(1)
            try context.pushToStack(2)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.bool(at: -1), false)
        } catch let error {
            fail(with: opcode, error: error)
        }
    }

    func testOpHash160() {
        let opcode = OpCode.OP_HASH160

        // OP_HASH160 success
        do {
            let data = "hello".data(using: .utf8)!
            try context.pushToStack(data)
            XCTAssertEqual(context.stack.count, 1)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1).hex, "b6a9c8c230722b7c748331a8b450f05566dc7d0f")
        } catch let error {
            fail(with: opcode, error: error)
        }

        // OP_HASH160 fail
        do {
            context.resetStack()
            XCTAssertEqual(context.stack.count, 0)
            try opcode.execute(context)
        } catch OpCodeExecutionError.opcodeRequiresItemsOnStack(1) {
            // do nothing equal success
        } catch let error {
            fail(with: opcode, error: error)
        }
    }

    func testOpCheckSig() {
        let opcode = OpCode.OP_CHECKSIG

        // Transaction in testnet3
        // https://api.blockcypher.com/v1/btc/test3/txs/0189910c263c4d416d5c5c2cf70744f9f6bcd5feaf0b149b02e5d88afbe78992
        let prevTxID = "1524ca4eeb9066b4765effd472bc9e869240c4ecb5c1ee0edb40f8b666088231"
        let hash = Data(Data(hex: prevTxID)!.reversed())
        let index: UInt32 = 1
        let outpoint = TransactionOutPoint(hash: hash, index: index)

        let balance: Int64 = 169012961

        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")

        let fromPublicKey = privateKey.publicKey()

        let subScript = Data(hex: "76a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac")!
        let inputForSign = TransactionInput(previousOutput: outpoint, signatureScript: subScript, sequence: UInt32.max)
        let unsignedTx = Transaction(version: 1, inputs: [inputForSign], outputs: [], lockTime: 0)

        // sign
        let hashType: SighashType = SighashType.BTC.ALL
        let utxoToSign = TransactionOutput(value: balance, lockingScript: subScript)
        let _txHash = unsignedTx.signatureHash(for: utxoToSign, inputIndex: 0, hashType: hashType)
        guard let signature: Data = try? Crypto.sign(_txHash, privateKey: privateKey) else {
            XCTFail("Failed to sign tx.")
            return
        }

        let sigData: Data = signature + UInt8(hashType)
        let pubkeyData: Data = fromPublicKey.raw

        // OP_CHECKSIG success
        do {
            context = ScriptExecutionContext(
                transaction: Transaction(
                    version: 1,
                    inputs: [TransactionInput(
                        previousOutput: TransactionOutPoint(hash: Data(), index: 0),
                        signatureScript: Data(),
                        sequence: 0)],
                    outputs: [],
                    lockTime: 0),
                utxoToVerify: utxoToSign,
                inputIndex: 0)
            try context.pushToStack(sigData) // sigData
            try context.pushToStack(pubkeyData) // pubkeyData
            try opcode.execute(context)
        } catch let error {
            fail(with: opcode, error: error)
        }

        // OP_CHECKSIG fail
        do {
            context = ScriptExecutionContext()
            try context.pushToStack("".data(using: .utf8)!) // sigData
            try context.pushToStack("".data(using: .utf8)!) // pubkeyData
            try opcode.execute(context)
        } catch OpCodeExecutionError.error("The transaction or the utxo to verify is not set.") {
            // do nothing equal success
        } catch let error {
            XCTFail("Shoud throw OpCodeExecutionError.error(\"The transaction or the utxo to verify is not set.\", but threw \(error)")
        }
    }

    func testOpInvalidOpCode() {
        let opcode = OpCode.OP_INVALIDOPCODE
        XCTAssertEqual(opcode.name, "OP_INVALIDOPCODE")
        XCTAssertEqual(opcode.value, 0xff)

        do {
            try opcode.execute(context)
        } catch OpCodeExecutionError.error("OP_INVALIDOPCODE should not be executed.") {
            // success
        } catch let error {
            XCTFail("Shoud throw OpCodeExecutionError.error(\"OP_INVALIDOPCODE should not be executed.\", but threw \(error)")
        }
    }
}

private func pushRandomDataOnStack(_ context: ScriptExecutionContext) {
    context.resetStack()
    let rand = arc4random() % 50 + 1
    for _ in (0..<rand) {
        let nextRand = arc4random() % 32
        switch nextRand {
        case 0...16:
            try! context.pushToStack(Int32(nextRand))
        default:
            let extraRand = arc4random()
            try! context.pushToStack(Data(from: extraRand))
        }
    }
}

private func fail(with opCode: OpCodeProtocol, error: Error) {
    XCTFail("\(opCode.name)(\(opCode.value)) execution should not fail.\nError: \(error)")
}
