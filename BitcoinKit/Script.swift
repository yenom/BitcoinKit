//
//  Script.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/30.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public struct Script {
    // Opcode
    private static let OP_DUP: Data = 0x76
    private static let OP_HASH160: Data = 0xa9
    private static let OP_0: Data = 0x14
    private static let OP_EQUALVERIFY: Data = 0x88
    private static let OP_CHECKSIG: Data = 0xac

    // Standard Transaction to Bitcoin address (pay-to-pubkey-hash)
    // scriptPubKey: OP_DUP OP_HASH160 OP_0 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
    public static func buildPublicKeyHashOut(pubKeyHash: Data) -> Data {
        let data: [Data] = [
            OP_DUP,
            OP_HASH160,
            OP_0,
            pubKeyHash,
            OP_EQUALVERIFY,
            OP_CHECKSIG
        ]
        return data.reduce(Data(), +)
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
