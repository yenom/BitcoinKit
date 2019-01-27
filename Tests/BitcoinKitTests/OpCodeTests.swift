//
//  OpCodeTests.swift
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

class OpCodeTests: XCTestCase {
    var context: ScriptExecutionContext!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        context = ScriptExecutionContext()
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
    
    func testOpCat() {
        let opcode = OpCode.OP_CAT
        
        // maxlen_x y OP_CAT -> failure
        // Concatenating any operand except an empty vector, including a single byte value (e.g. OP_1),
        // onto a maximum sized array causes failure
        do {
            try context.pushToStack(Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
            try context.pushToStack(1)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error when push value size limit exceeded.")
        } catch OpCodeExecutionError.error("Push value size limit exceeded") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"Push value size limit exceeded\"), but threw \(error)")
        }
        
        // large_x large_y OP_CAT -> failure
        // Concatenating two operands, where the total length is greater than MAX_SCRIPT_ELEMENT_SIZE, causes failure
        do {
            context.resetStack()
            try context.pushToStack(Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE / 2 + 1))
            try context.pushToStack(Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE / 2))
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error when push value size limit exceeded.")
        } catch OpCodeExecutionError.error("Push value size limit exceeded") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"Push value size limit exceeded\"), but threw \(error)")
        }
        
        // OP_0 OP_0 OP_CAT -> OP_0
        // Concatenating two empty arrays results in an empty array
        do {
            context.resetStack()
            try context.pushToStack(Data())
            try context.pushToStack(Data())
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1), Data())
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // x OP_0 OP_CAT -> x
        // Concatenating an empty array onto any operand results in the operand, including when len(x) = MAX_SCRIPT_ELEMENT_SIZE
        do {
            context.resetStack()
            try context.pushToStack(Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
            try context.pushToStack(Data())
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1), Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // OP_0 x OP_CAT -> x
        // Concatenating any operand onto an empty array results in the operand, including when len(x) = MAX_SCRIPT_ELEMENT_SIZE
        do {
            context.resetStack()
            try context.pushToStack(Data())
            try context.pushToStack(Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1), Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {Ox11} {0x22, 0x33} OP_CAT -> 0x112233
        // Concatenating two operands generates the correct result
        do {
            context.resetStack()
            try context.pushToStack(Data([0x11]))
            try context.pushToStack(Data([0x22, 0x33]))
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1), Data([0x11, 0x22, 0x33]))
        } catch let error {
            fail(with: opcode, error: error)
        }
    }

    func testOpSize() {
        let opcode = OpCode.OP_SIZE
        // OP_SIZE succeeds
        do {
            try context.pushToStack(Data([0x01]))
            XCTAssertEqual(context.stack.count, 1)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(try context.number(at: -1), 1)
            XCTAssertEqual(context.data(at: -2), Data([0x01]))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // OP_SIZE succeeds with empty array
        do {
            context.resetStack()
            try context.pushToStack(Data())
            XCTAssertEqual(context.stack.count, 1)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(try context.number(at: -1), 0)
            XCTAssertEqual(context.data(at: -2), Data())
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // OP_SIZE succeeds with maximum sized array case
        do {
            context.resetStack()
            try context.pushToStack(Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
            XCTAssertEqual(context.stack.count, 1)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(try context.number(at: -1), Int32(BTC_MAX_SCRIPT_ELEMENT_SIZE))
            XCTAssertEqual(context.data(at: -2), Data(count: BTC_MAX_SCRIPT_ELEMENT_SIZE))
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
    func testOpSplit() {
        let opcode = OpCode.OP_SPLIT
        // OP_0 0 OP_SPLIT -> OP_0 OP_0
        // Execution of OP_SPLIT on empty array results in two empty arrays.
        do {
            try context.pushToStack(Data())
            try context.pushToStack(0)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1), Data())
            XCTAssertEqual(context.data(at: -2), Data())
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // x 0 OP_SPLIT -> OP_0 x
        do {
            context.resetStack()
            try context.pushToStack(Data([0x01]))
            try context.pushToStack(0)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1), Data([0x01]))
            XCTAssertEqual(context.data(at: -2), Data())
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // x len(x) OP_SPLIT -> x OP_0
        do {
            context.resetStack()
            try context.pushToStack(Data([0x01]))
            try context.pushToStack(Int32(Data([0x01]).count))
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1), Data())
            XCTAssertEqual(context.data(at: -2), Data([0x01]))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // x (len(x) + 1) OP_SPLIT -> FAIL
        do {
            context.resetStack()
            try context.pushToStack(Data([0x01]))
            try context.pushToStack(Int32(Data([0x01]).count + 1))
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error with Invalid OP_SPLIT range.")
        } catch OpCodeExecutionError.error("Invalid OP_SPLIT range") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"Invalid OP_SPLIT range\"), but threw \(error)")
        }
        
        // successful cases
        // {0x00, 0x11, 0x22} 0 OP_SPLIT -> OP_0 {0x00, 0x11, 0x22}
        do {
            context.resetStack()
            try context.pushToStack(Data([0x00, 0x11, 0x22]))
            try context.pushToStack(0)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1), Data([0x00, 0x11, 0x22]))
            XCTAssertEqual(context.data(at: -2), Data())
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {0x00, 0x11, 0x22} 1 OP_SPLIT -> {0x00} {0x11, 0x22}
        do {
            context.resetStack()
            try context.pushToStack(Data([0x00, 0x11, 0x22]))
            try context.pushToStack(1)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1), Data([0x11, 0x22]))
            XCTAssertEqual(context.data(at: -2), Data([0x00]))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {0x00, 0x11, 0x22} 2 OP_SPLIT -> {0x00, 0x11} {0x22}
        do {
            context.resetStack()
            try context.pushToStack(Data([0x00, 0x11, 0x22]))
            try context.pushToStack(2)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1), Data([0x22]))
            XCTAssertEqual(context.data(at: -2), Data([0x00, 0x11]))
        } catch let error {
            fail(with: opcode, error: error)
        }
        
        // {0x00, 0x11, 0x22} 3 OP_SPLIT -> {0x00, 0x11, 0x22} OP_0
        do {
            context.resetStack()
            try context.pushToStack(Data([0x00, 0x11, 0x22]))
            try context.pushToStack(3)
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 2)
            XCTAssertEqual(context.data(at: -1), Data())
            XCTAssertEqual(context.data(at: -2), Data([0x00, 0x11, 0x22]))
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
    func testOpInvert() {
        let opcode = OpCode.OP_INVERT
        
        do {
            try opcode.execute(context)
        } catch OpCodeExecutionError.disabled {
            // success
        } catch let error {
            XCTFail("Shoud throw OpCodeExecutionError.disabled, but threw \(error)")
        }
    }
    
    func testOpAnd() {
        let opcode = OpCode.OP_AND
        
        // x1 x2 OP_AND -> failure, where len(x1) != len(x2). The two operands must be the same size.
        do {
            try context.pushToStack(Data(count: 1))
            try context.pushToStack(Data(count: 3))
            try opcode.execute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error with Invalid operand size.")
        } catch OpCodeExecutionError.error("Invalid operand size") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"Invalid operand size\"), but threw \(error)")
        }
        
        // x1 x2 OP_AND -> x1 & x2. Check valid results.
        do {
            context.resetStack()
            try context.pushToStack(Data(from: 0b11111100))
            try context.pushToStack(Data(from: 0b00111111))
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1), Data(from: 0b00111100))
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
    func testOpOr() {
        let opcode = OpCode.OP_OR
        
        // x1 x2 OP_OR -> failure, where len(x1) != len(x2). The two operands must be the same size.
        do {
            try context.pushToStack(Data(count: 1))
            try context.pushToStack(Data(count: 3))
            try opcode.execute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error with Invalid operand size.")
        } catch OpCodeExecutionError.error("Invalid operand size") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"Invalid operand size\"), but threw \(error)")
        }
        
        // x1 x2 OP_OR -> x1 | x2. Check valid results.
        do {
            context.resetStack()
            try context.pushToStack(Data(from: 0b10110010))
            try context.pushToStack(Data(from: 0b01011110))
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1), Data(from: 0b11111110))
        } catch let error {
            fail(with: opcode, error: error)
        }
    }
    
    func testOpXor() {
        let opcode = OpCode.OP_XOR
        
        // x1 x2 OP_XOR -> failure, where len(x1) != len(x2). The two operands must be the same size.
        do {
            try context.pushToStack(Data(count: 1))
            try context.pushToStack(Data(count: 3))
            try opcode.execute(context)
            XCTFail("\(opcode.name)(\(opcode.value) execution should throw error with Invalid operand size.")
        } catch OpCodeExecutionError.error("Invalid operand size") {
            // success
        } catch let error {
            XCTFail("Should throw OpCodeExecutionError .error(\"Invalid operand size\"), but threw \(error)")
        }
        
        // x1 x2 OP_XOR -> x1 xor x2. Check valid results.
        do {
            context.resetStack()
            try context.pushToStack(Data(from: 0b00010100))
            try context.pushToStack(Data(from: 0b00000101))
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.data(at: -1), Data(from: 0b00010001))
        } catch let error {
            fail(with: opcode, error: error)
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
        } catch OpCodeExecutionError.error("OP_EQUALVERIFY failed.") {
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

    func testOpCheckSigBTC() {
        let opcode = OpCode.OP_CHECKSIG

        // BTC Transaction in testnet3
        // https://api.blockcypher.com/v1/btc/test3/txs/0189910c263c4d416d5c5c2cf70744f9f6bcd5feaf0b149b02e5d88afbe78992
        let prevTxID = "1524ca4eeb9066b4765effd472bc9e869240c4ecb5c1ee0edb40f8b666088231"
        let hash = Data(Data(hex: prevTxID)!.reversed())
        let index: UInt32 = 1
        let outpoint = TransactionOutPoint(hash: hash, index: index)

        let balance: UInt64 = 169012961

        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")

        let fromPublicKey = privateKey.publicKey()

        let subScript = Data(hex: "76a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac")!
        let inputForSign = TransactionInput(previousOutput: outpoint, signatureScript: subScript, sequence: UInt32.max)
        let unsignedTx = Transaction(version: 1, timestamp: nil, inputs: [inputForSign], outputs: [], lockTime: 0)

        // sign
        let hashType: SighashType = SighashType.BTC.ALL
        let utxoToSign = TransactionOutput(value: balance, lockingScript: subScript)
        let _txHash = unsignedTx.signatureHash(for: utxoToSign, inputIndex: 0, hashType: hashType)
        guard let signature: Data = try? Crypto.sign(_txHash, privateKey: privateKey) else {
            XCTFail("Failed to sign tx.")
            return
        }

        let sigData: Data = signature + UInt8(hashType)
        let pubkeyData: Data = fromPublicKey.data

        // OP_CHECKSIG success
        do {
            context = ScriptExecutionContext(
                transaction: unsignedTx,
                utxoToVerify: utxoToSign,
                inputIndex: 0)
            try context.pushToStack(sigData) // sigData
            try context.pushToStack(pubkeyData) // pubkeyData
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.bool(at: -1), true)
        } catch let error {
            fail(with: opcode, error: error)
        }

        // OP_CHECKSIG success(invalid signature)
        do {
            context = ScriptExecutionContext(
                transaction: Transaction(
                    version: 1,
                    timestamp: nil,
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
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.bool(at: -1), false)
        } catch let error {
            fail(with: opcode, error: error)
        }

        // OP_CHECKSIG fail
        do {
            context = ScriptExecutionContext()
            XCTAssertEqual(context.stack.count, 0)
            try context.pushToStack("".data(using: .utf8)!) // sigData
            try context.pushToStack("".data(using: .utf8)!) // pubkeyData
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
        } catch OpCodeExecutionError.error("The transaction or the utxo to verify is not set.") {
            // do nothing equal success
        } catch let error {
            XCTFail("Shoud throw OpCodeExecutionError.error(\"The transaction or the utxo to verify is not set.\", but threw \(error)")
        }
    }

    func testOpCheckSigBCH() {
        let opcode = OpCode.OP_CHECKSIG

        // BCH Transaction
        // https://blockchair.com/bitcoin-cash/transaction/a793605eaed2c08c3f4c7906dd1526238ea04e9a16c785d46988c8cbd56f5088
        let prevTxID = "3b3ffd3f597cc114c14b3655f61da60258e2ff69388cd2e463c60504a0d98f78"
        let hash = Data(Data(hex: prevTxID)!.reversed())
        let index: UInt32 = 1
        let outpoint = TransactionOutPoint(hash: hash, index: index)

        let balance: UInt64 = 2047900000

        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")

        let fromPublicKey = privateKey.publicKey()

        let subScript = Data(hex: "30440220356c7a8d55d4a63b1eab9cf00886cb66fe114d31f59faf242295e0e6e2aec9e5022052b6c4ee09b6564edf5a6d13f386e43ca6f9b4af19e9fefea413ac28d5b8d2df41036b7b02cc5592256d22e45c2c70c41b34e962cc370bcf672cea6f476e1db318c8")!
        let inputForSign = TransactionInput(previousOutput: outpoint, signatureScript: subScript, sequence: UInt32.max)
        let unsignedTx = Transaction(version: 1, timestamp: nil, inputs: [inputForSign], outputs: [], lockTime: 0)

        // sign
        let hashType: SighashType = SighashType.BCH.ALL
        let utxoToSign = TransactionOutput(value: balance, lockingScript: subScript)
        let _txHash = unsignedTx.signatureHash(for: utxoToSign, inputIndex: 0, hashType: hashType)
        guard let signature: Data = try? Crypto.sign(_txHash, privateKey: privateKey) else {
            XCTFail("Failed to sign tx.")
            return
        }

        let sigData: Data = signature + UInt8(hashType)
        let pubkeyData: Data = fromPublicKey.data

        // OP_CHECKSIG success
        do {
            context = ScriptExecutionContext(
                transaction: unsignedTx,
                utxoToVerify: utxoToSign,
                inputIndex: 0)
            try context.pushToStack(sigData) // sigData
            try context.pushToStack(pubkeyData) // pubkeyData
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.bool(at: -1), true)
        } catch let error {
            fail(with: opcode, error: error)
        }

        // OP_CHECKSIG success(invalid signature)
        do {
            context = ScriptExecutionContext(
                transaction: Transaction(
                    version: 1,
                    timestamp: nil,
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
            XCTAssertEqual(context.stack.count, 2)
            try opcode.execute(context)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(context.bool(at: -1), false)
        } catch let error {
            fail(with: opcode, error: error)
        }

        // OP_CHECKSIG fail
        do {
            context = ScriptExecutionContext()
            XCTAssertEqual(context.stack.count, 0)
            try context.pushToStack("".data(using: .utf8)!) // sigData
            try context.pushToStack("".data(using: .utf8)!) // pubkeyData
            XCTAssertEqual(context.stack.count, 2)
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
