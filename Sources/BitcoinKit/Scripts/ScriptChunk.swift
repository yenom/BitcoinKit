//
//  ScriptChunk.swift
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

import Foundation

public protocol ScriptChunk {
    // Reference to the whole script binary data.
    var scriptData: Data { get }
    // A range of scriptData represented by this chunk.
    var range: Range<Int> { get }

    // Portion of scriptData defined by range.
    var chunkData: Data { get }
    // OP_CODE of scriptData defined by range.
    var opCode: OpCode { get }
    // String representation of a chunk.
    var string: String { get }

    // OP_1NEGATE, OP_0, OP_1..OP_16 are represented as a decimal number.
    // Most compactly represented pushdata chunks >=128 bit are encoded as <hex string>
    // Smaller most compactly represented data is encoded as [<hex string>]
    // Non-compact pushdata (e.g. 75-byte string with PUSHDATA1) contains a decimal prefix denoting a length size before hex data in square brackets. Ex. "1:[...]", "2:[...]" or "4:[...]"
    // For both compat and non-compact pushdata chunks, if the data consists of all printable characters (0x20..0x7E), it is enclosed not in square brackets, but in single quotes as characters themselves. Non-compact string is prefixed with 1:, 2: or 4: like described above.

    // Some other guys (BitcoinQT, bitcoin-ruby) encode "small enough" integers in decimal numbers and do that differently.
    // BitcoinQT encodes any data less than 4 bytes as a decimal number.
    // bitcoin-ruby encodes 2..16 as decimals, 0 and -1 as opcode names and the rest is in hex.
    // Now no matter which encoding you use, it can be parsed incorrectly.
    // Also: pushdata operations are typically encoded in a raw data which can be encoded in binary differently.
    // This means, you'll never be able to parse a sane-looking script into only one binary.
    // So forget about relying on parsing this thing exactly. Typically, we either have very small numbers (0..16),
    // or very big numbers (hashes and pubkeys).
}

extension ScriptChunk {
    public var opCode: OpCode {
        return OpCodeFactory.get(with: opcodeValue)
    }

    public var opcodeValue: UInt8 {
        return UInt8(scriptData[range.lowerBound])
    }

    public var chunkData: Data {
        return scriptData.subdata(in: range)
    }

    public func updated(scriptData data: Data) -> ScriptChunk {
        if self is DataChunk {
            return DataChunk(scriptData: data, range: range)
        } else {
            return OpcodeChunk(scriptData: data, range: range)
        }
    }

    public func updated(scriptData data: Data, range updatedRange: Range<Int>) -> ScriptChunk {
        if self is DataChunk {
            return DataChunk(scriptData: data, range: updatedRange)
        } else {
            return OpcodeChunk(scriptData: data, range: updatedRange)
        }
    }

}

public struct OpcodeChunk: ScriptChunk {
    public var scriptData: Data
    public var range: Range<Int>

    public init(scriptData: Data, range: Range<Int>) {
        self.scriptData = scriptData
        self.range = range
    }

    public var string: String {
        return opCode.name
    }
}

public struct DataChunk: ScriptChunk {
    public var scriptData: Data
    public var range: Range<Int>

    public init(scriptData: Data, range: Range<Int>) {
        self.scriptData = scriptData
        self.range = range
    }

    public var pushedData: Data {
        return data
    }

    private var data: Data {
        var loc: Int = 1
        if opCode == OpCode.OP_PUSHDATA1 {
            loc += 1
        } else if opCode == OpCode.OP_PUSHDATA2 {
            loc += 2
        } else if opCode == OpCode.OP_PUSHDATA4 {
            loc += 4
        }

        return scriptData.subdata(in: Range((range.lowerBound + loc)..<(range.upperBound)))
    }

    public var string: String {
        var string: String
        guard !data.isEmpty else {
            return "OP_0" // Empty data is encoded as OP_0.
        }

        if isASCIIData(data: data) {
            string = String(data: data, encoding: String.Encoding.ascii)!

            // Escape escapes & single quote characters.
            string = string.replacingOccurrences(of: "\\", with: "\\\\")
            string = string.replacingOccurrences(of: "'", with: "\\'")

            // Wrap in single quotes. Why not double? Because they are already used in JSON and we don't want to multiply the mess.
            string = "'" + string + "'"
        } else {
            string = data.hex

            // Shorter than 128-bit chunks are wrapped in square brackets to avoid ambiguity with big all-decimal numbers.
            if data.count < 16 {
                string = "[\(string)]"
            }
        }
        // Non-compact data is prefixed with an appropriate length prefix.
        if !isDataCompact {
            var prefix = 1
            if opCode == OpCode.OP_PUSHDATA2 {
                prefix = 2
            } else if opCode == OpCode.OP_PUSHDATA4 {
                prefix = 4
            }

            string = String(prefix) + ":" + string
        }
        return string
    }

    // Returns true if the data is represented with the most compact opcode.
    public var isDataCompact: Bool {
        switch opCode.value {
        case ...OpCode.OP_PUSHDATA1.value:
            return true // length fits in one byte under OP_PUSHDATA1.
        case OpCode.OP_PUSHDATA1.value:
            return data.count >= OpCode.OP_PUSHDATA1.value // length should not be less than OP_PUSHDATA1
        case OpCode.OP_PUSHDATA2.value:
            return data.count > (0xff) // length should not fit in one byte
        case OpCode.OP_PUSHDATA4.value:
            return data.count > (0xffff) // length should not fit in two bytes
        default:
            return false
        }
    }

    private func isASCIIData(data: Data) -> Bool {
        for ch in data {
            if !(ch >= 0x20 && ch <= 0x7E) {
                return false
            }
        }
        return true
    }
}
