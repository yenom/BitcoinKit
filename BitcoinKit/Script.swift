//
//  Script.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/30.
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 Shun Usami
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

public class Script {
    public var chunks: [ScriptChunk] // An array of Data objects (pushing data) or UInt8 objects (containing opcodes)

    // TODO: need to be cached
    // Cached serialized representations for -data and -string methods.
    public var data: Data {
        // When we calculate data from scratch, it's important to respect actual offsets in the chunks as they may have been copied or shifted in subScript* methods.
        var md = Data()
        for chunk in self.chunks {
            md += chunk.chunkData
        }
        return md
    }

    public typealias MultisigRequirements = (nSigRequired: UInt, publickeys: [PublicKey])
    // Multisignature script attributes.
    // If multisig script is not detected, both are NULL.
    public var multisigRequirements: MultisigRequirements?

    init() {
        self.chunks = [ScriptChunk]()
    }

    init(chunks: [ScriptChunk]) {
        self.chunks = chunks
    }

    convenience init?(data: Data) {
        // It's important to keep around original data to correctly identify the size of the script for BTC_MAX_SCRIPT_SIZE check
        // and to correctly calculate hash for the signature because in BitcoinQT scripts are not re-serialized/canonicalized.
        guard let chunks = Script.parseData(data) else {
            return nil
        }
        self.init(chunks: chunks)
    }

    convenience init?(hex: String) {
        guard let data = Data(hex: hex) else {
            return nil
        }
        self.init(data: data)
    }

    convenience init?(address: Address) {
        var resultData: Data = Data()

        switch address.type {
        case .pubkeyHash:
            // OP_DUP OP_HASH160 <hash> OP_EQUALVERIFY OP_CHECKSIG
            resultData += Opcode.OP_DUP
            resultData += Opcode.OP_HASH160

            resultData += VarInt(address.data.count).serialized()
            resultData += address.data

            resultData += Opcode.OP_EQUALVERIFY
            resultData += Opcode.OP_CHECKSIG
        case .scriptHash:
            // OP_HASH160 <hash> OP_EQUAL
            resultData += Opcode.OP_HASH160

            resultData += VarInt(address.data.count).serialized()
            resultData += address.data

            resultData += Opcode.OP_EQUAL
        default:
            return nil
        }
        self.init(data: resultData)
    }

    //    // OP_<M> <pubkey1> ... <pubkeyN> OP_<N> OP_CHECKMULTISIG
    convenience init?(publicKeys: [PublicKey], signaturesRequired: UInt) {
        // First make sure the arguments make sense.
        // We need at least one signature
        guard signaturesRequired > 0 else {
            return nil
        }

        // And we cannot have more signatures than available pubkeys.
        guard publicKeys.count > signaturesRequired else {
            return nil
        }

        // Both M and N should map to OP_<1..16>
        let mOpcode: UInt8 = Opcode.opcodeForSmallInteger(smallInteger: Int(signaturesRequired))
        let nOpcode: UInt8 = Opcode.opcodeForSmallInteger(smallInteger: publicKeys.count)

        guard mOpcode != Opcode.OP_INVALIDOPCODE else {
            return nil
        }
        guard nOpcode != Opcode.OP_INVALIDOPCODE else {
            return nil
        }

        var data: Data = Data()
        data += mOpcode

        for pubkey in publicKeys {
            guard let d = ScriptChunk.scriptData(for: pubkey.raw, preferredLengthEncoding: -1) else {
                return nil // invalid data
            }
            data += d
        }

        data += nOpcode
        data += Opcode.OP_CHECKMULTISIG

        self.init(data: data)
        self.multisigRequirements = (signaturesRequired, publicKeys)
    }

    public var hex: String {
        return self.data.hex
    }

    // TODO: need to be cached
    public var string: String {
        var buffer = [String]()
        for chunk in self.chunks {
            if let string = chunk.string {
                buffer.append(string)
            }
        }
        return buffer.joined(separator: " ")
    }

    private static func parseData(_ data: Data) -> [ScriptChunk]? {
        guard !data.isEmpty else {
            return [ScriptChunk]()
        }

        var chunks = [ScriptChunk]()

        var i: Int = 0
        let count: Int = data.count

        while i < count {
            // Exit if failed to parse
            guard let chunk = ScriptChunk.parseChunk(from: data, offset: i) else {
                return nil
            }
            chunks.append(chunk)

            i += chunk.range.count
        }
        return chunks
    }

    public var isStandard: Bool {
        return isPayToPublicKeyHashScript
            || isPayToScriptHashScript
            || isPublicKeyScript
            || isStandardMultisignatureScript
    }

    public var isPublicKeyScript: Bool {
        guard chunks.count == 2 else {
            return false
        }
        guard let pushdata = pushedData(at: 0) else {
            return false
        }
        return pushdata.count > 1 && opcode(at: 1) == Opcode.OP_CHECKSIG
    }

    public var isPayToPublicKeyHashScript: Bool {
        guard chunks.count == 5 else {
            return false
        }
        let dataChunk = chunk(at: 2)
        return opcode(at: 0) == Opcode.OP_DUP
            && opcode(at: 1) == Opcode.OP_HASH160
            && !dataChunk.isOpcode
            && dataChunk.range.count == 21
            && opcode(at: 3) == Opcode.OP_EQUALVERIFY
            && opcode(at: 4) == Opcode.OP_CHECKSIG
    }

    // TODO: check against the original serialized form instead of parsed chunks because BIP16 defines
    // P2SH script as an exact byte template. Scripts using OP_PUSHDATA1/2/4 are not valid P2SH scripts.
    // To do that we have to maintain original script binary data and each chunk should keep a range in that data.
    public var isPayToScriptHashScript: Bool {
        guard chunks.count == 3 else {
            return false
        }
        return opcode(at: 0) == Opcode.OP_HASH160
            && pushedData(at: 1)?.count == 20 // this is enough to match the exact byte template, any other encoding will be larger.
            && opcode(at: 2) == Opcode.OP_EQUAL
    }

    // Returns true if the script ends with P2SH check.
    // Not used in CoreBitcoin. Similar code is used in bitcoin-ruby. I don't know if we'll ever need it.
    public var endsWithPayToScriptHash: Bool {
        guard chunks.count >= 3 else {
            return false
        }
        return opcode(at: -3) == Opcode.OP_HASH160
            && pushedData(at: -2)?.count == 20
            && opcode(at: -1) == Opcode.OP_EQUAL
    }

    public var isStandardMultisignatureScript: Bool {
        guard isMultisignatureScript else {
            return false
        }
        guard let multisigPublicKeys = multisigRequirements?.publickeys else {
            return false
        }
        return multisigPublicKeys.count <= 3
    }

    public var isMultisignatureScript: Bool {
        if multisigRequirements?.nSigRequired == 0 {
            detectMultisigScript()
        }
        guard let nSingRequired = multisigRequirements?.nSigRequired else {
            return false
        }
        return nSingRequired > 0
    }

    // If typical multisig tx is detected, sets two ivars:
    private func detectMultisigScript() {
        // multisig script must have at least 4 ops ("OP_1 <pubkey> OP_1 OP_CHECKMULTISIG")
        guard chunks.count >= 4 else {
            return
        }

        // The last op is multisig check.
        guard opcode(at: -1) == Opcode.OP_CHECKMULTISIG else {
            return
        }

        let mOpcode: UInt8 = opcode(at: 0)
        let nOpcode: UInt8 = opcode(at: -2)

        let m: Int = Opcode.smallIntegerFromOpcode(opcode: mOpcode)
        let n: Int = Opcode.smallIntegerFromOpcode(opcode: nOpcode)

        guard m > 0 && m != Int.max else {
            return
        }
        guard n > 0 && n != Int.max && n >= m else {
            return
        }

        // We must have correct number of pubkeys in the script. 3 extra ops: OP_<M>, OP_<N> and OP_CHECKMULTISIG
        guard chunks.count == 3 + n else {
            return
        }

        var pubkeys: [PublicKey] = []
        for i in 0...n {
            guard let data = pushedData(at: i) else {
                return
            }
            let pubkey = PublicKey(bytes: data, network: .mainnet)
            pubkeys.append(pubkey)
        }

        // Now we extracted all pubkeys and verified the numbers.
        multisigRequirements?.nSigRequired = UInt(m)
        multisigRequirements?.publickeys = pubkeys
    }

    // Include both PUSHDATA ops and OP_0..OP_16 literals.
    public var isDataOnly: Bool {
        return !chunks.contains { $0.opcode > Opcode.OP_16 }
    }

    public var scriptChunks: [ScriptChunk] {
        return chunks
    }

    public func enumerateOperations(block: (_ opIndex: Int, _ opcode: UInt8, _ pushData: Data?) -> Bool) {
        for (opIndex, chunk) in chunks.enumerated() {
            if chunk.isOpcode {
                if block(opIndex, chunk.opcode, nil) {
                    return
                }
            } else {
                if block(opIndex, Opcode.OP_INVALIDOPCODE, chunk.pushedData) {
                    return
                }
            }
        }
    }

    public var standardAddress: Address? {
        if isPayToPublicKeyHashScript {
            guard chunks.count == 5 else {
                return nil
            }
            let dataChunk = chunk(at: 2)

            if !dataChunk.isOpcode && dataChunk.range.count == 21 {
                // return [BTCPublicKeyAddress addressWithData:dataChunk.pushdata];
                // TODO: Addressでdata, type, networkを引数にとるinitializerが必要

            }
        } else if isPayToScriptHashScript {
            guard chunks.count == 3 else {
                return nil
            }
            let dataChunk = chunk(at: 1)

            if !dataChunk.isOpcode && dataChunk.range.count == 21 {
                // return [BTCScriptHashAddress addressWithData:dataChunk.pushdata];
                // TODO: Addressでdata, type, networkを引数にとるinitializerが必要
            }
        }
        return nil
    }

    public func invalidateSerialization() {
        // TODO: set nil for cached self.data and self.string
        multisigRequirements = nil
    }

    public func append(opcode: UInt8) -> Script {
        var scriptData: Data = data
        scriptData += opcode

        var updatedChunks = [ScriptChunk]()

        // Update reference to a new data for all chunks.
        // ScriptChunkがStructなので、updateするためには新たにScriptChunkを作る必要がある
        for chunk in chunks {
            let updatedChunk = ScriptChunk(scriptData: scriptData, range: chunk.range)
            updatedChunks.append(updatedChunk)
        }

        let range = Range(scriptData.count - MemoryLayout.size(ofValue: opcode)..<scriptData.count)
        let chunk = ScriptChunk(scriptData: scriptData, range: range)
        updatedChunks.append(chunk)

        chunks = updatedChunks
        invalidateSerialization()

        return self
    }

    public func append(data: Data) -> Script {
        guard !data.isEmpty else {
            return self
        }

        var scriptData: Data = self.data

        guard let addedScriptData = ScriptChunk.scriptData(for: data, preferredLengthEncoding: -1) else {
            return self
        }
        scriptData.append(addedScriptData)

        var updatedChunks = [ScriptChunk]()

        // Update reference to a new data for all chunks.
        for chunk in chunks {
            let updatedChunk = ScriptChunk(scriptData: scriptData, range: chunk.range)
            updatedChunks.append(updatedChunk)
        }

        let range = Range(scriptData.count - addedScriptData.count..<scriptData.count)
        let chunk = ScriptChunk(scriptData: scriptData, range: range)
        updatedChunks.append(chunk)

        chunks = updatedChunks
        invalidateSerialization()

        return self
    }

    public func append(otherScript: Script) -> Script {
        guard !otherScript.data.isEmpty else {
            return self
        }

        var scriptData: Data = self.data

        let offset: Int = scriptData.count

        scriptData.append(otherScript.data)

        var updatedChunks = [ScriptChunk]()

        // Update reference to a new data for all chunks.
        for chunk in chunks {
            let updatedChunk = ScriptChunk(scriptData: scriptData, range: chunk.range)
            updatedChunks.append(updatedChunk)
        }

        for chunk in otherScript.chunks {
            let range = Range(chunk.range.lowerBound + offset..<scriptData.count)
            let chunk2 = ScriptChunk(scriptData: scriptData, range: range)
            updatedChunks.append(chunk2)
        }

        chunks = updatedChunks
        invalidateSerialization()

        return self
    }

    public func deleteOccurrences(of data: Data) -> Script {
        guard !data.isEmpty else {
            return self
        }

        let updatedData = chunks.filter { $0.pushedData != data }.reduce(Data()) { $0 + $1.chunkData }
        guard let updatedChunks = Script.parseData(updatedData) else {
            return self
        }

        chunks = updatedChunks
        return self
    }

    public func deleteOccurrences(of opcode: UInt8) -> Script {
        let updatedData = chunks.filter { $0.opcode != opcode }.reduce(Data()) { $0 + $1.chunkData }
        guard let updatedChunks = Script.parseData(updatedData) else {
            return self
        }

        chunks = updatedChunks
        return self
    }

    public func subScript(from index: Int) -> Script? {
        let subChunks = chunks[Range(index..<chunks.count)]
        let updatedData = subChunks.reduce(Data()) { $0 + $1.chunkData }
        return Script(data: updatedData)
    }

    public func subScript(to index: Int) -> Script? {
        let subChunks = chunks[Range(0..<index)]
        let updatedData = subChunks.reduce(Data()) { $0 + $1.chunkData }
        return Script(data: updatedData)
    }

    // Raise exception if index is out of bounds
    public func chunk(at index: Int) -> ScriptChunk {
        return chunks[index < 0 ? chunks.count + index : index]
    }

    // Returns an opcode in a chunk.
    // If the chunk is data, not an opcode, returns OP_INVALIDOPCODE
    // Raises exception if index is out of bounds.
    public func opcode(at index: Int) -> UInt8 {
        let chunk = self.chunk(at: index)
        // If the chunk is not actually an opcode, return invalid opcode.
        guard chunk.isOpcode else {
            return Opcode.OP_INVALIDOPCODE
        }
        return chunk.opcode
    }

    // Returns NSData in a chunk.
    // If chunk is actually an opcode, returns nil.
    // Raises exception if index is out of bounds.
    public func pushedData(at index: Int) -> Data? {
        let chunk = self.chunk(at: index)
        guard !chunk.isOpcode else {
            return nil
        }
        return chunk.pushedData
    }
}

extension Script {
    // Standard Transaction to Bitcoin address (pay-to-pubkey-hash)
    // scriptPubKey: OP_DUP OP_HASH160 OP_0 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
    public static func buildPublicKeyHashOut(pubKeyHash: Data) -> Data {
        let tmp: Data = Data() + Opcode.OP_DUP + Opcode.OP_HASH160 + Opcode.OP_0 + pubKeyHash + Opcode.OP_EQUALVERIFY
        return tmp + Opcode.OP_CHECKSIG
    }

    public static func buildPublicKeyUnlockingScript(signature: Data, pubkey: PublicKey, hashType: SighashType) -> Data {
        var data: Data = Data([UInt8(signature.count + 1)]) + signature + UInt8(hashType)
        data += VarInt(pubkey.raw.count).serialized()
        data += pubkey.raw
        return data
    }

    public static func isPublicKeyHashOut(_ script: Data) -> Bool {
        return script.count == 25 &&
            script[0] == Opcode.OP_DUP && script[1] == Opcode.OP_HASH160 && script[2] == Opcode.OP_0 &&
            script[23] == Opcode.OP_EQUALVERIFY && script[24] == Opcode.OP_CHECKSIG
    }

    public static func getPublicKeyHash(from script: Data) -> Data {
        return script[3..<23]
    }
}

extension Script: CustomStringConvertible {
    public var description: String {
        return string
    }
}
