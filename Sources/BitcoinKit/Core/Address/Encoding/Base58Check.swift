//
//  Base58Check.swift
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

/// Version = 1 byte of 0 (zero); on the test network, this is 1 byte of 111
/// Key hash = Version concatenated with RIPEMD-160(SHA-256(public key))
/// Checksum = 1st 4 bytes of SHA-256(SHA-256(Key hash))
/// Bitcoin Address = Base58Encode(Key hash concatenated with Checksum)
/// Base58 encoding/decoding with checksum verification
/// ```
/// // Encode bytes to address
/// let address = Base58Check.encode([versionByte] + pubkeyHash)
///
/// // Decode address to bytes
/// guard let payload = Base58Check.decode(address) else {
///     // Possible cause 1: Coding format is invalid
///     // Possible cause 2: Checksum is invalid
///     throw SomeError()
/// }
/// let versionByte = payload[0]
/// let pubkeyHash = payload.dropFirst()
/// ```
public struct Base58Check {
    public static func encode(_ bytes: Data) -> String {
        let checksum: Data = Crypto.sha256sha256(bytes).prefix(4)
        return Base58.encode(bytes + checksum)
    }
    public static func decode(_ string: String) -> Data? {
        guard let raw = Base58.decode(string) else {
            return nil
        }
        let checksum = raw.suffix(4)
        let payload = raw.dropLast(4)
        let checksumConfirm = Crypto.sha256sha256(payload).prefix(4)
        guard checksum == checksumConfirm else {
            return nil
        }

        return payload
    }
}
