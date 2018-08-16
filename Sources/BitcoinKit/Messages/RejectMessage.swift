//
//  RejectMessage.swift
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

/// The reject message is sent when messages are rejected.
public struct RejectMessage {
    /// type of message rejected
    public let message: VarString
    /// code relating to rejected message
    /// 0x01  REJECT_MALFORMED
    /// 0x10  REJECT_INVALID
    /// 0x11  REJECT_OBSOLETE
    /// 0x12  REJECT_DUPLICATE
    /// 0x40  REJECT_NONSTANDARD
    /// 0x41  REJECT_DUST
    /// 0x42  REJECT_INSUFFICIENTFEE
    /// 0x43  REJECT_CHECKPOINT
    public let ccode: UInt8
    /// text version of reason for rejection
    public let reason: VarString
    /// Optional extra data provided by some errors.
    /// Currently, all errors which provide this field fill it with the TXID or
    /// block header hash of the object being rejected, so the field is 32 bytes.
    public let data: Data

    public static func deserialize(_ data: Data) -> RejectMessage {
        let byteStream = ByteStream(data)
        let message = byteStream.read(VarString.self)
        let ccode = byteStream.read(UInt8.self)
        let reason = byteStream.read(VarString.self)
        return RejectMessage(message: message, ccode: ccode, reason: reason, data: Data())
    }
}
