//
//  BitcoinAddress+Legacy.swift
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
    /// Base58Check encoded bitcoin address format
    public var legacy: String {
        switch hashType {
        case .pubkeyHash:
            return Base58Check.encode([network.pubkeyhash] + data)
        case .scriptHash:
            return Base58Check.encode([network.pubkeyhash] + data)
        }
    }

    /// Creates a new BitcoinAddress instance with Base58Check encoded address.
    ///
    /// The network will be .mainnetBTC or .testnetBTC. This initializer performs
    /// base58check and hash size validation.
    /// ```
    /// let address = try BitcoinAddress(legacy: "1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
    /// ```
    ///
    /// - Parameter legacy: Base58Check encoded String value to use as the source of the new
    ///   instance. It must be without scheme.
    public init(legacy: String) throws {
        // Hash size is 160 bits
        self.hashSize = .bits160

        // Base58Check decode
        guard let pubKeyHash = Base58Check.decode(legacy) else {
            throw AddressError.invalid
        }

        let networkVersionByte = pubKeyHash[0]

        // Network
        switch networkVersionByte {
        case Network.mainnetBTC.pubkeyhash, Network.mainnetBTC.scripthash:
            network = .mainnetBTC
        case Network.testnetBTC.pubkeyhash, Network.testnetBTC.scripthash:
            network = .testnetBTC
        default:
            throw AddressError.invalidVersionByte
        }

        // hash type
        switch networkVersionByte {
        case Network.mainnetBTC.pubkeyhash, Network.testnetBTC.pubkeyhash:
            hashType = .pubkeyHash
        case Network.mainnetBTC.scripthash, Network.testnetBTC.scripthash:
            hashType = .scriptHash
        default:
            throw AddressError.invalidVersionByte
        }

        self.data = pubKeyHash.dropFirst()

        // validate data size
        guard data.count == hashSize.sizeInBytes else {
            throw AddressError.invalid
        }
    }
}
