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

/// A set of Base58Check coding methods.
///
/// ```
/// // Encode bytes to address
/// let address = Base58Check.encode([versionByte] + pubkeyHash)
///
/// // Decode address to bytes
/// guard let payload = Base58Check.decode(address) else {
///     // Invalid checksum or Base58 coding
///     throw SomeError()
/// }
/// let versionByte = payload[0]
/// let pubkeyHash = payload.dropFirst()
/// ```
public struct Base58Check {
    /// Encodes the data to Base58Check encoded string
    ///
    /// Puts checksum bytes to the original data and then, encode the combined
    /// data to Base58 string.
    /// ```
    /// let address = Base58Check.encode([versionByte] + pubkeyHash)
    /// ```
    public static func encode(_ payload: Data) -> String {
        let checksum: Data = Crypto.sha256sha256(payload).prefix(4)
        return Base58.encode(payload + checksum)
    }

    /// Decode the Base58 encoded String value to original payload
    ///
    /// First validate if checksum bytes are the first 4 bytes of the sha256(sha256(payload)).
    /// If it's valid, returns the original payload.
    /// ```
    /// let payload = Base58Check.decode(base58checkText)
    /// ```
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
