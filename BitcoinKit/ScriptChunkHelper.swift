//
//  ScriptChunkHelper.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/22.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
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

        if data.count < Opcode.OP_PUSHDATA1 && preferredLengthEncoding <= 0 {
            // do nothing
            scriptData += UInt8(data.count)
        } else if data.count <= (0xff) && (preferredLengthEncoding == -1 || preferredLengthEncoding == 1) {
            scriptData += Opcode.OP_PUSHDATA1
            scriptData += UInt8(data.count)
        } else if data.count <= (0xffff) && (preferredLengthEncoding == -1 || preferredLengthEncoding == 2) {
            scriptData += Opcode.OP_PUSHDATA2
            scriptData += UInt16(data.count)
        } else if UInt64(data.count) <= 0xffffffff && (preferredLengthEncoding == -1 || preferredLengthEncoding == 4) {
            scriptData += Opcode.OP_PUSHDATA4
            scriptData += UInt64(data.count)
        } else {
            // Invalid preferredLength encoding or data size is too big.
            return nil
        }
        scriptData += data
        return scriptData
    }

    public static func parseChunk(from scriptData: Data, offset: Int) -> ScriptChunk? {
        // Data should fit at least one opcode.
        guard scriptData.count > offset else {
            return nil
        }

        let opcode: UInt8 = scriptData[offset]

        guard opcode <= Opcode.OP_PUSHDATA4 else {
            // simple opcode
            let range = Range(offset..<offset + MemoryLayout.size(ofValue: opcode))
            return OpcodeChunk(scriptData: scriptData, range: range)
        }

        let count: Int = scriptData.count
        let chunkLength: Int

        if opcode < Opcode.OP_PUSHDATA1 {
            let dataLength = opcode
            chunkLength = MemoryLayout.size(ofValue: opcode) + Int(dataLength)
        } else if opcode == Opcode.OP_PUSHDATA1 {
            var dataLength = UInt8()
            guard offset + MemoryLayout.size(ofValue: dataLength) <= count else {
                return nil
            }
            _ = scriptData.withUnsafeBytes {
                memcpy(&dataLength, $0 + offset + MemoryLayout.size(ofValue: opcode), MemoryLayout.size(ofValue: dataLength))
            }
            chunkLength = MemoryLayout.size(ofValue: opcode) + MemoryLayout.size(ofValue: dataLength) + Int(dataLength)
        } else if opcode == Opcode.OP_PUSHDATA2 {
            var dataLength = UInt16()
            guard offset + MemoryLayout.size(ofValue: dataLength) <= count else {
                return nil
            }
            _ = scriptData.withUnsafeBytes {
                memcpy(&dataLength, $0 + offset + MemoryLayout.size(ofValue: opcode), MemoryLayout.size(ofValue: dataLength))
            }
            dataLength = CFSwapInt16LittleToHost(dataLength)
            chunkLength = MemoryLayout.size(ofValue: opcode) + MemoryLayout.size(ofValue: dataLength) + Int(dataLength)
        } else if opcode == Opcode.OP_PUSHDATA4 {
            var dataLength = UInt32()
            guard offset + MemoryLayout.size(ofValue: dataLength) <= count else {
                return nil
            }
            _ = scriptData.withUnsafeBytes {
                memcpy(&dataLength, $0 + offset + MemoryLayout.size(ofValue: opcode), MemoryLayout.size(ofValue: dataLength))
            }
            dataLength = CFSwapInt32LittleToHost(dataLength) // CoreBitcoin uses CFSwapInt16LittleToHost(dataLength)
            chunkLength = MemoryLayout.size(ofValue: opcode) + MemoryLayout.size(ofValue: dataLength) + Int(dataLength)
        } else {
            return nil  // never comes here
            // because opcode is surely OP_PUSHDATA1, OP_PUSHDATA2, or OP_PUSHDATA4
        }

        guard offset + chunkLength <= count else {
            return nil
        }
        let range: Range<Int> = Range(offset..<offset + chunkLength)
        return DataChunk(scriptData: scriptData, range: range)
    }
}
