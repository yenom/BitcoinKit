//
//  NetworkAddress.swift
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

/// When a network address is needed somewhere,
/// this structure is used. Network addresses are not prefixed with a timestamp in the version message.
public struct NetworkAddress {
    public let services: UInt64
    public let address: String
    public let port: UInt16

    public func serialized() -> Data {
        var data = Data()
        data += services.littleEndian
        data += pton(address)
        data += port.bigEndian
        return data
    }

    static func deserialize(_ byteStream: ByteStream) -> NetworkAddress {
        let services = byteStream.read(UInt64.self)
        let address = parseIP(data: byteStream.read(Data.self, count: 16))
        let port = byteStream.read(UInt16.self)
        return NetworkAddress(services: services, address: address, port: port)
    }

    static private func parseIP(data: Data) -> String {
        let address = ipv6(from: data)
        if address.hasPrefix("0000:0000:0000:0000:0000:ffff") {
            return "0000:0000:0000:0000:0000:ffff:" + ipv4(from: data)
        } else {
            return address
        }
    }
}

extension NetworkAddress: CustomStringConvertible {
    public var description: String {
        return "[\(address)]:\(port.bigEndian) \(ServiceFlags(rawValue: services))"
    }
}
