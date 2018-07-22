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
//  This file has been modified by the BitcoinCashKit developers for the BitcoinCashKit project.
//  The original file was from the bitcoinj project (https://github.com/kishikawakatsumi/BitcoinKit).
//

import Foundation

public struct ScriptChunk {
    var scriptData: Data // Reference to the whole script binary data.
    var range: Range<Int> // A range of scriptData represented by this chunk.

    init(scriptData: Data, range: Range<Int>) {
        self.scriptData = scriptData
        self.range = range
    }

    // Operation to be executed.
    public var opcode: UInt8 {
        return UInt8(scriptData[range.lowerBound])
    }

    // Pushdedata opcodes are not considered a single "opcode".
    // Attention: OP_0 is also "pushdata" code that pushes empty data.
    public var isOpcode: Bool {
        return opcode > Opcode.OP_PUSHDATA4
    }

    // Portion of scriptData defined by range.
    public var chunkData: Data {
        return scriptData.subdata(in: range)
    }

    // Data being pushed. Returns nil if the opcode is not OP_PUSHDATA*.
    public var pushedData: Data? {
        guard !isOpcode else {
            return nil
        }
        var loc = 1
        switch opcode {
        case Opcode.OP_PUSHDATA1:
            loc += 1
        case Opcode.OP_PUSHDATA2:
            loc += 2
        case Opcode.OP_PUSHDATA4:
            loc += 4
        default:
            break
        }
        return scriptData.subdata(in: Range((range.lowerBound + loc)...(range.upperBound)))
    }

    // Returns true if the data is represented with the most compact opcode.
    public var isDataCompact: Bool {
        guard !isOpcode else {
            return false
        }
        guard let data = pushedData else {
            return false
        }
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
    public var string: String? {
        if isOpcode {
            return Opcode.getOpcodeName(with: opcode)
        } else {
            var string: String
            guard let data = pushedData, !data.isEmpty else {
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
                if opcode == Opcode.OP_PUSHDATA2 {
                    prefix = 2
                } else if opcode == Opcode.OP_PUSHDATA4 {
                    prefix = 4
                }
                string = String(prefix) + ":" + string
            }
            return string
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

    // If encoding is -1, then the most compact will be chosen.
    // Valid values: -1, 0, 1, 2, 4.
    // Returns nil if preferredLengthEncoding can't be used for data, or data is nil or too big.
    public static func scriptData(for pushedData: Data?, preferredLengthEncoding: Int) -> Data? {
        guard let data = pushedData else {
            return nil
        }

        var scriptData: Data = Data()

        if data.count < Opcode.OP_PUSHDATA1 && preferredLengthEncoding <= 0 {
            // do nothing
        } else if data.count <= (0xff) && (preferredLengthEncoding == -1 || preferredLengthEncoding == 1) {
            scriptData += Opcode.OP_PUSHDATA1
        } else if data.count <= (0xffff) && (preferredLengthEncoding == -1 || preferredLengthEncoding == 2) {
            scriptData += Opcode.OP_PUSHDATA2
        } else if UInt64(data.count) <= 0xffffffff && (preferredLengthEncoding == -1 || preferredLengthEncoding == 4) {
            scriptData += Opcode.OP_PUSHDATA4
        } else {
            // Invalid preferredLength encoding or data size is too big.
            return nil
        }
        scriptData += data.count
        scriptData += data
        return scriptData
    }

    // swiftlint:disable:next cyclomatic_complexity
    public static func parseChunk(from scriptData: Data, offset: Int) -> ScriptChunk? {
        // Data should fit at least one opcode.
        guard scriptData.count >= (offset + 1) else {
            return nil
        }

        let opcode: UInt8 = scriptData[offset]

        if opcode <= Opcode.OP_PUSHDATA4 {
            let count: Int = scriptData.count
            let range: Range<Int>

            if opcode < Opcode.OP_PUSHDATA1 {
                let dataLength = opcode
                let chunkLength = MemoryLayout.size(ofValue: opcode) + Int(dataLength)

                guard offset + chunkLength <= count else {
                    return nil
                }
                range = Range(offset..<offset + chunkLength)
            } else if opcode == Opcode.OP_PUSHDATA1 {
                var dataLength = UInt8()
                guard offset + MemoryLayout.size(ofValue: dataLength) <= count else {
                    return nil
                }
                _ = scriptData.withUnsafeBytes {
                    memcpy(&dataLength, $0 + offset + MemoryLayout.size(ofValue: opcode), MemoryLayout.size(ofValue: dataLength))
                }
                let chunkLength = MemoryLayout.size(ofValue: opcode) + MemoryLayout.size(ofValue: dataLength) + Int(dataLength)
                guard offset + chunkLength <= count else {
                    return nil
                }
                range = Range(offset..<offset + chunkLength)
            } else if opcode == Opcode.OP_PUSHDATA2 {
                var dataLength = UInt16()
                guard offset + MemoryLayout.size(ofValue: dataLength) <= count else {
                    return nil
                }
                _ = scriptData.withUnsafeBytes {
                    memcpy(&dataLength, $0 + offset + MemoryLayout.size(ofValue: opcode), MemoryLayout.size(ofValue: dataLength))
                }
                dataLength = CFSwapInt16LittleToHost(dataLength)
                let chunkLength = MemoryLayout.size(ofValue: opcode) + MemoryLayout.size(ofValue: dataLength) + Int(dataLength)
                guard offset + chunkLength <= count else {
                    return nil
                }
                range = Range(offset..<offset + chunkLength)
            } else if opcode == Opcode.OP_PUSHDATA4 {
                var dataLength = UInt32()
                guard offset + MemoryLayout.size(ofValue: dataLength) <= count else {
                    return nil
                }
                _ = scriptData.withUnsafeBytes {
                    memcpy(&dataLength, $0 + offset + MemoryLayout.size(ofValue: opcode), MemoryLayout.size(ofValue: dataLength))
                }
                dataLength = CFSwapInt32LittleToHost(dataLength) // CoreBitcoin uses CFSwapInt16LittleToHost(dataLength)
                let chunkLength = MemoryLayout.size(ofValue: opcode) + MemoryLayout.size(ofValue: dataLength) + Int(dataLength)
                guard offset + chunkLength <= count else {
                    return nil
                }
                range = Range(offset..<offset + chunkLength)
            } else {
                return nil  // never comes here
                // because opcode is surely OP_PUSHDATA1, OP_PUSHDATA2, or OP_PUSHDATA4
            }
            return ScriptChunk(scriptData: scriptData, range: range)
        } else {
            // simple opcode
            let range = Range(offset..<offset + MemoryLayout.size(ofValue: opcode))
            return ScriptChunk(scriptData: scriptData, range: range)
        }
    }
}
