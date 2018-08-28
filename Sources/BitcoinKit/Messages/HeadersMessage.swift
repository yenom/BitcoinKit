//
//  HeadersMessage.swift
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

public struct HeadersMessage {
    // The main client will never send us more than this number of headers.
    public static let MAX_HEADERS: Int = 2000

    /// Number of block headers
    public var count: VarInt {
        return VarInt(headers.count)
    }
    /// Block headers
    public let headers: [BlockMessage]

    public func serialized() -> Data {
        var data = Data()
        data += count.serialized()
        for header in headers {
            data += header.serialized()
        }
        return data
    }

    public static func deserialize(_ data: Data) throws -> HeadersMessage {
        let byteStream = ByteStream(data)
        let count = byteStream.read(VarInt.self)
        let countValue = count.underlyingValue
        guard countValue <= MAX_HEADERS else {
            throw ProtocolError.error("Too many headers: got \(countValue) which is larger than \(MAX_HEADERS)")
        }
        var blockHeaders = [BlockMessage]()
        for _ in 0..<countValue {
            let blockHeader: BlockMessage = BlockMessage.deserialize(byteStream)
            guard blockHeader.transactions.isEmpty else {
                throw ProtocolError.error("Block header does not have transaction")
            }
            blockHeaders.append(blockHeader)
        }
        return HeadersMessage(headers: blockHeaders)
    }
}
