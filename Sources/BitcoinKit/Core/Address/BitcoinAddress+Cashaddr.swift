//
//  BitcoinAddress+Cashaddr.swift
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

extension BitcoinAddress {
    public var versionByte: VersionByte {
        return VersionByte(hashType, hashSize)
    }

    /// Bech32 encoded bitcoincash address format
    public var cashaddr: String {
        let scheme: BitcoinScheme
        switch network {
        case .mainnetBCH: scheme = .bitcoincash
        case .testnetBCH: scheme = .bchtest
        case .mainnetBTC: scheme = .bitcoincash
        case .testnetBTC: scheme = .bchtest
        default:
            assertionFailure("cashaddr is only supported for \(network).")
            scheme = .bitcoincash
        }
        return Bech32.encode(payload: [versionByte.rawValue] + data, prefix: scheme.rawValue)
    }

    /// Creates a new BitcoinAddress with the bech32 encoded address with scheme.
    ///
    /// The network will be .mainnetBTC or .testnetBTC. This initializer performs
    /// prefix validation, bech32 decode, and hash size validation.
    ///
    /// ```
    /// let address = try BitcoinAddress(cashaddr: "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
    /// ```
    ///
    /// - Parameter bech32: Bech32 encoded String value to use as the source of the new
    ///   instance. It must come with scheme "bitcioncash:" or "bchtest:".
    public init(cashaddr: String) throws {
        // prefix validation and decode
        guard let decoded = Bech32.decode(cashaddr) else {
            throw AddressError.invalid
        }

        switch BitcoinScheme(scheme: decoded.prefix) {
        case .some(.bitcoincash):
            network = .mainnetBCH
        case .some(.bchtest):
            network = .testnetBCH
        default:
            throw AddressError.invalidScheme
        }

        let payload = decoded.data
        guard let versionByte = VersionByte(payload[0]) else {
            throw AddressError.invalidVersionByte
        }
        self.hashType = versionByte.hashType
        self.hashSize = versionByte.hashSize

        self.data = payload.dropFirst()

        // validate data size
        guard data.count == hashSize.sizeInBytes else {
            throw AddressError.invalidVersionByte
        }
    }
}
