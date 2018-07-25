//
//  ScriptChunk.swift
//  BitcoinKit
//
//  Created by Akifumi Fujita on 2018/07/09.
//  Copyright © 2018 Akifumi Fujita
//  Copyright © 2018 BitcoinCashKit developers
//  Licensed under the Apache License, Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public protocol ScriptChunk {
    // Reference to the whole script binary data.
    var scriptData: Data { get }
    // A range of scriptData represented by this chunk.
    var range: Range<Int> { get }

    // Portion of scriptData defined by range.
    var chunkData: Data { get }
    // Data being pushed. Returns nil if the opcode is not OP_PUSHDATA*.
    var pushedData: Data? { get }
    // Operation to be executed.
    var opcode: UInt8 { get }
    // String representation of a chunk.
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
    var string: String { get }
}

extension ScriptChunk {
    public var opcode: UInt8 {
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

    init(scriptData: Data, range: Range<Int>) {
        self.scriptData = scriptData
        self.range = range
    }

    public let pushedData: Data? = nil

    public var string: String {
        return Opcode.getOpcodeName(with: opcode)
    }
}

public struct DataChunk: ScriptChunk {
    public var scriptData: Data
    public var range: Range<Int>

    init(scriptData: Data, range: Range<Int>) {
        self.scriptData = scriptData
        self.range = range
    }

    public var pushedData: Data? {
        return data
    }

    private var data: Data {
        var loc: Int = 1
        if opcode == Opcode.OP_PUSHDATA1 {
            loc += 1
        } else if opcode == Opcode.OP_PUSHDATA2 {
            loc += 2
        } else if opcode == Opcode.OP_PUSHDATA4 {
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
            if opcode == Opcode.OP_PUSHDATA2 { prefix = 2 } else if opcode == Opcode.OP_PUSHDATA4 { prefix = 4 }

            string = String(prefix) + ":" + string
        }
        return string
    }

    // Returns true if the data is represented with the most compact opcode.
    public var isDataCompact: Bool {
        switch opcode {
        case ...Opcode.OP_PUSHDATA1:
            return true // length fits in one byte under OP_PUSHDATA1.
        case Opcode.OP_PUSHDATA1:
            return data.count >= Opcode.OP_PUSHDATA1 // length should not be less than OP_PUSHDATA1
        case Opcode.OP_PUSHDATA2:
            return data.count > (0xff) // length should not fit in one byte
        case Opcode.OP_PUSHDATA4:
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
