//
//  OP_PUSHDATA.swift
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

import Foundation

// The next byte contains the number of bytes to be pushed onto the stack.
public struct OpPushData1: OpCodeProtocol {
    public var value: UInt8 { return 0x4c }
    public var name: String { return "OP_PUSHDATA1" }
}

// The next two bytes contain the number of bytes to be pushed onto the stack in little endian order.
public struct OpPushData2: OpCodeProtocol {
    public var value: UInt8 { return 0x4d }
    public var name: String { return "OP_PUSHDATA2" }
}

// The next four bytes contain the number of bytes to be pushed onto the stack in little endian order.
public struct OpPushData4: OpCodeProtocol {
    public var value: UInt8 { return 0x4e }
    public var name: String { return "OP_PUSHDATA4" }
}
