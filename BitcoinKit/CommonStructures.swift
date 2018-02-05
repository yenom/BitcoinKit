//
//  CommonStructures.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/30.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
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

/// Integer can be encoded depending on the represented value to save space.
/// Variable length integers always precede an array/vector of a type of data that may vary in length.
/// Longer numbers are encoded in little endian.
public struct VarInt : ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = UInt64
    public let underlyingValue: UInt64
    let length: UInt8
    let data: Data

    public init(integerLiteral value: UInt64) {
        self.init(value)
    }

    public init(_ value: UInt64) {
        underlyingValue = value

        switch value {
        case 0...252:
            length = 1
            data = Data() + UInt8(value).littleEndian
        case 253...0xffff:
            length = 2
            data = Data() + UInt8(0xfd).littleEndian + UInt16(value).littleEndian
        case 0x10000...0xffffffff:
            length = 4
            data = Data() + UInt8(0xfe).littleEndian + UInt32(value).littleEndian
        case 0x100000000...0xffffffffffffffff:
            fallthrough
        default:
            length = 8
            data = Data() + UInt8(0xff).littleEndian + UInt64(value).littleEndian
        }
    }

    public init(_ value: Int) {
        self.init(UInt64(value))
    }

    public func serialized() -> Data {
        return data
    }

    public static func deserialize(_ data: Data) -> VarInt {
        return data.to(type: self)
    }
}

extension VarInt : CustomStringConvertible {
    public var description: String {
        return "\(underlyingValue)"
    }
}

/// Variable length string can be stored using a variable length integer followed by the string itself.
public struct VarString : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public let length: VarInt
    public let value: String

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(_ value: String) {
        self.value = value
        length = VarInt(value.data(using: .ascii)!.count)
    }

    public func serialized() -> Data {
        var data = Data()
        data += length.serialized()
        data += value
        return data
    }
}

extension VarString : CustomStringConvertible {
    public var description: String {
        return "\(value)"
    }
}

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

extension NetworkAddress : CustomStringConvertible {
    public var description: String {
        return "[\(address)]:\(port.bigEndian) \(ServiceFlags(rawValue: services))"
    }
}

struct ServiceFlags : OptionSet {
    let rawValue: UInt64
    /// Nothing
    static let none = ServiceFlags(rawValue: 0)
    /// NODE_NETWORK means that the node is capable of serving the complete block chain. It is currently
    /// set by all Bitcoin Core non pruned nodes, and is unset by SPV clients or other light clients.
    static let network = ServiceFlags(rawValue: 1 << 0)
    /// NODE_GETUTXO means the node is capable of responding to the getutxo protocol request.
    /// Bitcoin Core does not support this but a patch set called Bitcoin XT does.
    /// See BIP 64 for details on how this is implemented.
    static let getutxo = ServiceFlags(rawValue: 1 << 1)
    /// NODE_BLOOM means the node is capable and willing to handle bloom-filtered connections.
    /// Bitcoin Core nodes used to support this by default, without advertising this bit,
    /// but no longer do as of protocol version 70011 (= NO_BLOOM_VERSION)
    static let bloom = ServiceFlags(rawValue: 1 << 2)
    /// NODE_WITNESS indicates that a node can be asked for blocks and transactions including
    /// witness data.
    static let witness = ServiceFlags(rawValue: 1 << 3)
    /// NODE_XTHIN means the node supports Xtreme Thinblocks
    /// If this is turned off then the node will not service nor make xthin requests
    static let xthin = ServiceFlags(rawValue: 1 << 4)
    /// NODE_NETWORK_LIMITED means the same as NODE_NETWORK with the limitation of only
    /// serving the last 288 (2 day) blocks
    /// See BIP159 for details on how this is implemented.
    static let networkLimited = ServiceFlags(rawValue: 1 << 10)
    // Bits 24-31 are reserved for temporary experiments. Just pick a bit that
    // isn't getting used, or one not being used much, and notify the
    // bitcoin-development mailing list. Remember that service bits are just
    // unauthenticated advertisements, so your code must be robust against
    // collisions and other cases where nodes may be advertising a service they
    // do not actually support. Other service bits should be allocated via the
    // BIP process.
}

extension ServiceFlags : CustomStringConvertible {
    var description: String {
        let strings = ["NODE_NETWORK", "NODE_GETUTXO", "NODE_BLOOM", "NODE_WITNESS", "NODE_XTHIN", "NODE_NETWORK_LIMITED"]
        var members = [String]()
        for (flag, string) in strings.enumerated() where self.contains(ServiceFlags(rawValue: 1 << (UInt8(flag)))) {
            members.append(string)
        }
        return members.joined(separator: "|")
    }
}
