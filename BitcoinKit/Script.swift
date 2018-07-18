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

public struct Script {
    // Opcode
    public static let OP_DUP: UInt8 = 0x76
    public static let OP_HASH160: UInt8 = 0xa9
    public static let OP_0: UInt8 = 0x14
    public static let OP_EQUALVERIFY: UInt8 = 0x88
    public static let OP_CHECKSIG: UInt8 = 0xac

    // Standard Transaction to Bitcoin address (pay-to-pubkey-hash)
    // scriptPubKey: OP_DUP OP_HASH160 OP_0 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
    public static func buildPublicKeyHashOut(pubKeyHash: Data) -> Data {
        let tmp: Data = Data() + OP_DUP + OP_HASH160 + OP_0 + pubKeyHash + OP_EQUALVERIFY
        return tmp + OP_CHECKSIG
    }

    public static func buildPublicKeyUnlockingScript(signature: Data, pubkey: PublicKey, hashType: SighashType) -> Data {
        var data: Data = Data([UInt8(signature.count + 1)]) + signature + UInt8(hashType)
        data += VarInt(pubkey.raw.count).serialized()
        data += pubkey.raw
        return data
    }

    public static func isPublicKeyHashOut(_ script: Data) -> Bool {
        return script.count == 25 &&
            script[0] == OP_DUP && script[1] == OP_HASH160 && script[2] == OP_0 &&
            script[23] == OP_EQUALVERIFY && script[24] == OP_CHECKSIG
    }

    public static func getPublicKeyHash(from script: Data) -> Data {
        return script[3..<23]
    }
}
