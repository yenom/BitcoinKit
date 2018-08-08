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
    
    func testOp0() {
        let opcode = OpCode.OP_0
        do {
            try opcode.execute(context)
            let num = try context.number(at: -1)
            XCTAssertEqual(context.stack.count, 1)
            XCTAssertEqual(num, 0)
        } catch let error {
            fail(with: opcode, error: error)
        }
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
                                               (OpCode.OP_0, 0),
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
            fail(with: opcode, error: error)
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
        } catch OpCodeExecutionError.error("OP_CHECKSIGVERIFY failed.") {
            // success
            XCTAssertEqual(context.stack.count, 1)
        } catch let error {
            fail(with: opcode, error: error)
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
