//
//  PublicKey.swift
//
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 BitcoinCashKit developers
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
import BitcoinCashKit.Private

public struct PublicKey {
    let raw: Data
    public var pubkeyHash: Data {
        return Crypto.sha256ripemd160(raw)
    }
    public let network: Network
    public let isCompressed: Bool

    init(privateKey: PrivateKey) {
        self.network = privateKey.network
        self.isCompressed = privateKey.isPublicKeyCompressed
        self.raw = PublicKey.from(privateKey: privateKey.raw, compression: privateKey.isPublicKeyCompressed)
    }

    init(bytes raw: Data, network: Network) {
        self.raw = raw
        self.network = network
        let header = raw[0]
        self.isCompressed = (header == 0x02 || header == 0x03)
    }

    /// Version = 1 byte of 0 (zero); on the test network, this is 1 byte of 111
    /// Key hash = Version concatenated with RIPEMD-160(SHA-256(public key))
    /// Checksum = 1st 4 bytes of SHA-256(SHA-256(Key hash))
    /// Bitcoin Address = Base58Encode(Key hash concatenated with Checksum)
    public func toAddress() -> String {
        let versionByte: Data = Data([network.pubkeyhash])
        return publicKeyHashToAddress(versionByte + pubkeyHash)
    }

    public func toCashaddr() -> String {
        let versionByte: Data = Data([VersionByte.pubkeyHash160])
        return Bech32.encode(versionByte + pubkeyHash, prefix: network.scheme)
    }

    static func from(privateKey raw: Data, compression: Bool = false) -> Data {
        return _Key.computePublicKey(fromPrivateKey: raw, compression: compression)
    }
}

extension PublicKey: Equatable {
    // swiftlint:disable:next operator_whitespace
    public static func ==(lhs: PublicKey, rhs: PublicKey) -> Bool {
        return lhs.network == rhs.network && lhs.raw == rhs.raw
    }
}

extension PublicKey: CustomStringConvertible {
    public var description: String {
        return raw.hex
    }
}
