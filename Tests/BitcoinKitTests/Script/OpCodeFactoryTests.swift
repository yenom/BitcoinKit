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

class OpCodeFactoryTests: XCTestCase {
    func testGetWithValue() {
        assert(OpCodeFactory.get(with: 0x00), OpCode.OP_0)
        assert(OpCodeFactory.get(with: 0x4c), OpCode.OP_PUSHDATA1)
        assert(OpCodeFactory.get(with: 0x4f), OpCode.OP_1NEGATE)
        assert(OpCodeFactory.get(with: 0x51), OpCode.OP_1)
        assert(OpCodeFactory.get(with: 0xa9), OpCode.OP_HASH160)
        assert(OpCodeFactory.get(with: 0xac), OpCode.OP_CHECKSIG)
        assert(OpCodeFactory.get(with: 0xff), OpCode.OP_INVALIDOPCODE)
    }
    
    func testGetWithName() {
        assert(OpCodeFactory.get(with: "OP_0"), OpCode.OP_0)
        assert(OpCodeFactory.get(with: "OP_PUSHDATA1"), OpCode.OP_PUSHDATA1)
        assert(OpCodeFactory.get(with: "OP_1NEGATE"), OpCode.OP_1NEGATE)
        assert(OpCodeFactory.get(with: "OP_1"), OpCode.OP_1)
        assert(OpCodeFactory.get(with: "OP_HASH160"), OpCode.OP_HASH160)
        assert(OpCodeFactory.get(with: "OP_CHECKSIG"), OpCode.OP_CHECKSIG)
        assert(OpCodeFactory.get(with: "OP_INVALIDOPCODE"), OpCode.OP_INVALIDOPCODE)
    }
    
    func testOpCodeForSmallInteger() {
        assert(OpCodeFactory.opcode(for: -1), OpCode.OP_1NEGATE)
        assert(OpCodeFactory.opcode(for: 0), OpCode.OP_0)
        assert(OpCodeFactory.opcode(for: 1), OpCode.OP_1)
        assert(OpCodeFactory.opcode(for: 8), OpCode.OP_8)
        assert(OpCodeFactory.opcode(for: 16), OpCode.OP_16)
        assert(OpCodeFactory.opcode(for: 17), OpCode.OP_INVALIDOPCODE)
        assert(OpCodeFactory.opcode(for: Int.min), OpCode.OP_INVALIDOPCODE)
        assert(OpCodeFactory.opcode(for: Int.max), OpCode.OP_INVALIDOPCODE)
    }
    
    func testSmallIntegerFromOpcode() {
        XCTAssertEqual(OpCodeFactory.smallInteger(from: OpCode.OP_1NEGATE), -1)
        XCTAssertEqual(OpCodeFactory.smallInteger(from: OpCode.OP_0), 0)
        XCTAssertEqual(OpCodeFactory.smallInteger(from: OpCode.OP_1), 1)
        XCTAssertEqual(OpCodeFactory.smallInteger(from: OpCode.OP_8), 8)
        XCTAssertEqual(OpCodeFactory.smallInteger(from: OpCode.OP_16), 16)
        XCTAssertEqual(OpCodeFactory.smallInteger(from: OpCode.OP_INVALIDOPCODE), Int.max)
    }
    
    private func assert(_ lhs: OpCodeProtocol, _ rhs: OpCodeProtocol) {
        XCTAssertEqual(lhs.name, rhs.name)
        XCTAssertEqual(lhs.value, rhs.value)
    }
}
