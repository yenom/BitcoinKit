//
//  ScriptChunkHelper.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/22.
//  Copyright © 2018 BitcoinCashKit developers. All rights reserved.
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

struct ScriptChunkHelper {
    // If encoding is -1, then the most compact will be chosen.
    // Valid values: -1, 0, 1, 2, 4.
    // Returns nil if preferredLengthEncoding can't be used for data, or data is nil or too big.
    public static func scriptData(for data: Data, preferredLengthEncoding: Int) -> Data? {
        var scriptData: Data = Data()

        if data.count < OpCode.OP_PUSHDATA1 && preferredLengthEncoding <= 0 {
            // do nothing
            scriptData += UInt8(data.count)
        } else if data.count <= (0xff) && (preferredLengthEncoding == -1 || preferredLengthEncoding == 1) {
            scriptData += OpCode.OP_PUSHDATA1
            scriptData += UInt8(data.count)
        } else if data.count <= (0xffff) && (preferredLengthEncoding == -1 || preferredLengthEncoding == 2) {
            scriptData += OpCode.OP_PUSHDATA2
            scriptData += UInt16(data.count)
        } else if UInt64(data.count) <= 0xffffffff && (preferredLengthEncoding == -1 || preferredLengthEncoding == 4) {
            scriptData += OpCode.OP_PUSHDATA4
            scriptData += UInt64(data.count)
        } else {
            // Invalid preferredLength encoding or data size is too big.
            return nil
        }
        scriptData += data
        return scriptData
    }

    // TODO: Make it throws and non-optional
    public static func parseChunk(from scriptData: Data, offset: Int) -> ScriptChunk? {
        // Data should fit at least one opcode.
        guard scriptData.count > offset else {
            return nil
        }

        let opcode: UInt8 = scriptData[offset]

        if opcode > OpCode.OP_PUSHDATA4 {
            // simple opcode
            let range = Range(offset..<offset + MemoryLayout.size(ofValue: opcode))
            return OpcodeChunk(scriptData: scriptData, range: range)
        } else {
            // push data
            return parseDataChunk(from: scriptData, offset: offset, opcode: opcode)
        }
    }

    private static func parseDataChunk(from scriptData: Data, offset: Int, opcode: UInt8) -> DataChunk? {
        // for range
        let count: Int = scriptData.count
        let chunkLength: Int

        switch opcode {
        case 0..<OpCode.OP_PUSHDATA1.value:
            let dataLength = opcode
            chunkLength = MemoryLayout.size(ofValue: opcode) + Int(dataLength)
        case OpCode.OP_PUSHDATA1.value:
            var dataLength = UInt8()
            guard offset + MemoryLayout.size(ofValue: dataLength) <= count else {
                print("\(opcode), OP_PUSHDATA1 error")
                return nil
            }
            _ = scriptData.withUnsafeBytes {
                memcpy(&dataLength, $0 + offset + MemoryLayout.size(ofValue: opcode), MemoryLayout.size(ofValue: dataLength))
            }
            chunkLength = MemoryLayout.size(ofValue: opcode) + MemoryLayout.size(ofValue: dataLength) + Int(dataLength)
        case OpCode.OP_PUSHDATA2.value:
            var dataLength = UInt16()
            guard offset + MemoryLayout.size(ofValue: dataLength) <= count else {
                print("\(opcode), OP_PUSHDATA2 error")
                return nil
            }
            _ = scriptData.withUnsafeBytes {
                memcpy(&dataLength, $0 + offset + MemoryLayout.size(ofValue: opcode), MemoryLayout.size(ofValue: dataLength))
            }
            dataLength = CFSwapInt16LittleToHost(dataLength)
            chunkLength = MemoryLayout.size(ofValue: opcode) + MemoryLayout.size(ofValue: dataLength) + Int(dataLength)
        case OpCode.OP_PUSHDATA4.value:
            var dataLength = UInt32()
            guard offset + MemoryLayout.size(ofValue: dataLength) <= count else {
                print("\(opcode), OP_PUSHDATA4 error")
                return nil
            }
            _ = scriptData.withUnsafeBytes {
                memcpy(&dataLength, $0 + offset + MemoryLayout.size(ofValue: opcode), MemoryLayout.size(ofValue: dataLength))
            }
            dataLength = CFSwapInt32LittleToHost(dataLength) // CoreBitcoin uses CFSwapInt16LittleToHost(dataLength)
            chunkLength = MemoryLayout.size(ofValue: opcode) + MemoryLayout.size(ofValue: dataLength) + Int(dataLength)
        default:
            // cannot happen because it's opcode
            return nil
        }

        guard offset + chunkLength <= count else {
            return nil
        }
        let range: Range<Int> = Range(offset..<offset + chunkLength)
        return DataChunk(scriptData: scriptData, range: range)
    }
}
