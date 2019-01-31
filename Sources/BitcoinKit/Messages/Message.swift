//
//  Message.swift
//  BitcoinKit
//
//  Created by Akifumi Fujita on 2019/01/27.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import Foundation

protocol Message {
    static var command: String { get }
    func serialized() -> Data
    static func deserialize(_ data: Data) throws -> Self
}

extension Message {
    func combineHeader(_ networkMagic: UInt32) -> Data {
        let payload = serialized()
        let checksum = Data(Crypto.sha256sha256(payload).prefix(upTo: 4))
        let header = MessageHeader(magic: networkMagic, command: Self.command, length: UInt32(payload.count), checksum: checksum)
        return header.serialized() + payload
    }
}

enum ProtocolError: Error {
    case error(String)
    case notImplemented
}
