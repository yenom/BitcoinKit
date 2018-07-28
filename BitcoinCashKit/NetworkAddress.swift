//
//  NetworkAddress.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/11.
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
