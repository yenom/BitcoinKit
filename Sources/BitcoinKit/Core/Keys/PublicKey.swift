//
//  PublicKey.swift
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
#if BitcoinKitXcode
import BitcoinKit.Private
#else
import BitcoinKitPrivate
#endif

public struct PublicKey {
    public let data: Data
    @available(*, deprecated, renamed: "data")
    public var raw: Data { return data }
    public var pubkeyHash: Data {
        return Crypto.sha256ripemd160(data)
    }
    public let network: Network
    public let isCompressed: Bool

    public init(bytes data: Data, network: Network) {
        self.data = data
        self.network = network
        let header = data[0]
        self.isCompressed = (header == 0x02 || header == 0x03)
    }

    /// Version = 1 byte of 0 (zero); on the test network, this is 1 byte of 111
    /// Key hash = Version concatenated with RIPEMD-160(SHA-256(public key))
    /// Checksum = 1st 4 bytes of SHA-256(SHA-256(Key hash))
    /// Bitcoin Address = Base58Encode(Key hash concatenated with Checksum)
    private func base58() -> String {
        let versionByte: Data = Data([network.pubkeyhash])
        return publicKeyHashToAddress(versionByte + pubkeyHash)
    }

    private func bech32() -> String {
        let versionByte: Data = Data([VersionByte.pubkeyHash160])
        return Bech32.encode(versionByte + pubkeyHash, prefix: network.scheme)
    }

    public func toLegacy() -> LegacyAddress {
        return LegacyAddress(data: pubkeyHash, type: .pubkeyHash, network: network, base58: base58(), bech32: bech32(), publicKey: data)
    }

    public func toCashaddr() -> Cashaddr {
        return Cashaddr(data: pubkeyHash, type: .pubkeyHash, network: network, base58: base58(), bech32: bech32(), publicKey: data)
    }
}

extension PublicKey: Equatable {
    public static func == (lhs: PublicKey, rhs: PublicKey) -> Bool {
        return lhs.network == rhs.network && lhs.data == rhs.data
    }
}

extension PublicKey: CustomStringConvertible {
    public var description: String {
        return data.hex
    }
}

#if os(iOS) || os(tvOS) || os(watchOS)
extension PublicKey: QRCodeConvertible {}
#endif
