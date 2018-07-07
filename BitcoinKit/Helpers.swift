//
//  Helpers.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/31.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

func ipv4(from data: Data) -> String {
    return Data(data.dropFirst(12)).map { String($0) }.joined(separator: ".")
}

func ipv6(from data: Data) -> String {
    return stride(from: 0, to: data.count - 1, by: 2).map { Data([data[$0], data[$0 + 1]]).hex }.joined(separator: ":")
}

func pton(_ address: String) -> Data {
    var addr = in6_addr()
    _ = withUnsafeMutablePointer(to: &addr) {
        inet_pton(AF_INET6, address, UnsafeMutablePointer($0))
    }
    var buffer = Data(count: 16)
    _ = buffer.withUnsafeMutableBytes { memcpy($0, &addr, 16) }
    return buffer
}

/// Version = 1 byte of 0 (zero); on the test network, this is 1 byte of 111
/// Key hash = Version concatenated with RIPEMD-160(SHA-256(public key))
/// Checksum = 1st 4 bytes of SHA-256(SHA-256(Key hash))
/// Bitcoin Address = Base58Encode(Key hash concatenated with Checksum)
func publicKeyHashToAddress(_ hash: Data) -> String {
    let checksum = Crypto.sha256sha256(hash).prefix(4)
    let address = Base58.encode(hash + checksum)
    return address
}

public class VersionByte {
    static let pubkeyHash160: UInt8 = PubkeyHash160().bytes
    static let scriptHash160: UInt8 = ScriptHash160().bytes
    var bytes: UInt8 {
        return type.rawValue + size.rawValue
    }

    public var type: TypeBits { return .pubkeyHash }
    public var size: SizeBits { return .size160 }

    // First 1 bit is zero
    // Next 4bits
    public enum TypeBits: UInt8 {
        case pubkeyHash = 0
        case scriptHash = 8
    }

    // The least 3bits
    public enum SizeBits: UInt8 {
        case size160 = 0
        case size192 = 1
        case size224 = 2
        case size256 = 3
        case size320 = 4
        case size384 = 5
        case size448 = 6
        case size512 = 7
    }
}

public class PubkeyHash160: VersionByte {
    public override var size: SizeBits { return .size160 }
    public override var type: TypeBits { return .pubkeyHash }
}
public class ScriptHash160: VersionByte {
    public override var size: SizeBits { return .size160 }
    public override var type: TypeBits { return .scriptHash }
}
