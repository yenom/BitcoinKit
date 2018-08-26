//
//  Message.swift
//
//  Copyright © 2018 Kishikawa Katsumi
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

public struct Message {
    /// Magic value indicating message origin network, and used to seek to next message when stream state is unknown
    public let magic: UInt32
    /// ASCII string identifying the packet content, NULL padded (non-NULL padding results in packet rejected)
    public let command: String
    /// Length of payload in number of bytes
    public let length: UInt32
    /// First 4 bytes of sha256(sha256(payload))
    public let checksum: Data
    /// The actual data
    public let payload: Data

    public static let minimumLength = 24

    public func serialized() -> Data {
        var data = Data()
        data += magic.bigEndian
        var bytes = [UInt8](command.data(using: .ascii)!)
        bytes.append(contentsOf: [UInt8](repeating: 0, count: 12 - bytes.count))
        data += bytes
        data += length.littleEndian
        data += checksum
        data += payload
        return data
    }

    public static func deserialize(_ data: Data) -> Message? {
        let byteStream = ByteStream(data)

        let magic = byteStream.read(UInt32.self)
        let command = byteStream.read(Data.self, count: 12).to(type: String.self)
        let length = byteStream.read(UInt32.self)
        let checksum = byteStream.read(Data.self, count: 4)

        guard length <= byteStream.availableBytes else {
            return nil
        }
        let payload = byteStream.read(Data.self, count: Int(length))

        let checksumConfirm = Crypto.sha256sha256(payload).prefix(4)
        guard checksum == checksumConfirm else {
            return nil
        }

        return Message(magic: magic, command: command, length: length, checksum: checksum, payload: payload)
    }
}

enum ProtocolError: Error {
    case error(String)
}
