//
//  Bech32.swift
// 
//  Copyright © 2019 BitcoinKit developers
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

/// A set of Bech32 coding methods.
///
/// ```
/// // Encode bytes to address
/// let cashaddr: String = Bech32.encode(payload: [versionByte] + pubkeyHash,
///                                      prefix: "bitcoincash")
///
/// // Decode address to bytes
/// guard let payload: Data = Bech32.decode(text: address) else {
///     // Invalid checksum or Bech32 coding
///     throw SomeError()
/// }
/// let versionByte = payload[0]
/// let pubkeyHash = payload.dropFirst()
/// ```
public struct Bech32 {
    internal static let base32Alphabets = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"

    /// Encodes the data to Bech32 encoded string
    ///
    /// Creates checksum bytes from the prefix and the payload, and then puts the
    /// checksum bytes to the original data. Then, encode the combined data to
    /// Base32 string. At last, returns the combined string of prefix, separator
    /// and the encoded base32 text.
    /// ```
    /// let address = Base58Check.encode(payload: [versionByte] + pubkeyHash,
    ///                                  prefix: "bitcoincash")
    /// ```
    /// - Parameters:
    ///   - payload: The data to encode
    ///   - prefix: The prefix of the encoded text. It is also used to create checksum.
    ///   - separator: separator that separates prefix and Base32 encoded text
    public static func encode(payload: Data, prefix: String, separator: String = ":") -> String {
        let payloadUint5 = convertTo5bit(data: payload, pad: true)
        let checksumUint5: Data = createChecksum(prefix: prefix, payload: payloadUint5) // Data of [UInt5]
        let combined: Data = payloadUint5 + checksumUint5 // Data of [UInt5]
        var base32 = ""
        for b in combined {
            let index = String.Index(utf16Offset: Int(b), in: base32Alphabets)
            base32 += String(base32Alphabets[index])
        }

        return prefix + separator + base32
    }

    @available(*, unavailable, renamed: "encode(payload:prefix:separator:)")
    public static func encode(_ bytes: Data, prefix: String, seperator: String = ":") -> String {
        return encode(payload: bytes, prefix: prefix, separator: seperator)
    }

    /// Decodes the Bech32 encoded string to original payload
    ///
    /// ```
    /// // Decode address to bytes
    /// guard let payload: Data = Bech32.decode(text: address) else {
    ///     // Invalid checksum or Bech32 coding
    ///     throw SomeError()
    /// }
    /// let versionByte = payload[0]
    /// let pubkeyHash = payload.dropFirst()
    /// ```
    /// - Parameters:
    ///   - string: The data to encode
    ///   - separator: separator that separates prefix and Base32 encoded text
    public static func decode(_ string: String, separator: String = ":") -> (prefix: String, data: Data)? {
        // We can't have empty string.
        // Bech32 should be uppercase only / lowercase only.
        guard !string.isEmpty && [string.lowercased(), string.uppercased()].contains(string) else {
            return nil
        }

        let components = string.components(separatedBy: separator)
        // We can only handle string contains both scheme and base32
        guard components.count == 2 else {
            return nil
        }
        let (prefix, base32) = (components[0], components[1])

        var decodedIn5bit: [UInt8] = [UInt8]()
        for c in base32.lowercased() {
            // We can't have characters other than base32 alphabets.
            guard let baseIndex = base32Alphabets.firstIndex(of: c)?.utf16Offset(in: base32Alphabets) else {
                return nil
            }
            decodedIn5bit.append(UInt8(baseIndex))
        }

        // We can't have invalid checksum
        let payload = Data(decodedIn5bit)
        guard verifyChecksum(prefix: prefix, payload: payload) else {
            return nil
        }

        // Drop checksum
        guard let bytes = try? convertFrom5bit(data: payload.dropLast(8)) else {
            return nil
        }
        return (prefix, Data(bytes))
    }
    @available(*, unavailable, renamed: "decode(string:separator:)")
    public static func decode(_ string: String, seperator: String = ":") -> (prefix: String, data: Data)? {
        return decode(string, separator: seperator)
    }

    internal static func verifyChecksum(prefix: String, payload: Data) -> Bool {
        return PolyMod(expand(prefix) + payload) == 0
    }

    internal static func expand(_ prefix: String) -> Data {
        var ret: Data = Data()
        let buf: [UInt8] = Array(prefix.utf8)
        for b in buf {
            ret += b & 0x1f
        }
        ret += Data(repeating: 0, count: 1)
        return ret
    }

    internal static func createChecksum(prefix: String, payload: Data) -> Data {
        let enc: Data = expand(prefix) + payload + Data(repeating: 0, count: 8)
        let mod: UInt64 = PolyMod(enc)
        var ret: Data = Data()
        for i in 0..<8 {
            ret += UInt8((mod >> (5 * (7 - i))) & 0x1f)
        }
        return ret
    }

    internal static func PolyMod(_ data: Data) -> UInt64 {
        var c: UInt64 = 1
        for d in data {
            let c0: UInt8 = UInt8(c >> 35)
            c = ((c & 0x07ffffffff) << 5) ^ UInt64(d)
            if c0 & 0x01 != 0 { c ^= 0x98f2bc8e61 }
            if c0 & 0x02 != 0 { c ^= 0x79b76d99e2 }
            if c0 & 0x04 != 0 { c ^= 0xf33e5fb3c4 }
            if c0 & 0x08 != 0 { c ^= 0xae2eabe2a8 }
            if c0 & 0x10 != 0 { c ^= 0x1e4f43e470 }
        }
        return c ^ 1
    }

    internal static func convertTo5bit(data: Data, pad: Bool) -> Data {
        var acc = Int()
        var bits = UInt8()
        let maxv: Int = 31 // 31 = 0x1f = 00011111
        var converted: [UInt8] = []
        for d in data {
            acc = (acc << 8) | Int(d)
            bits += 8

            while bits >= 5 {
                bits -= 5
                converted.append(UInt8(acc >> Int(bits) & maxv))
            }
        }

        let lastBits: UInt8 = UInt8(acc << (5 - bits) & maxv)
        if pad && bits > 0 {
            converted.append(lastBits)
        }
        return Data(converted)
    }

    internal static func convertFrom5bit(data: Data) throws -> Data {
        var acc = Int()
        var bits = UInt8()
        let maxv: Int = 255 // 255 = 0xff = 11111111
        var converted: [UInt8] = []
        for d in data {
            guard (d >> 5) == 0 else {
                throw DecodeError.invalidCharacter
            }
            acc = (acc << 5) | Int(d)
            bits += 5

            while bits >= 8 {
                bits -= 8
                converted.append(UInt8(acc >> Int(bits) & maxv))
            }
        }

        let lastBits: UInt8 = UInt8(acc << (8 - bits) & maxv)
        guard bits < 5 && lastBits == 0  else {
            throw DecodeError.invalidBits
        }

        return Data(converted)
    }

    internal enum DecodeError: Error {
        case invalidCharacter
        case invalidBits
    }
}
