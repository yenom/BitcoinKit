//
//  HDPublicKey.swift
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

public class HDPublicKey {
    public let network: Network
    public let depth: UInt8
    public let fingerprint: UInt32
    public let childIndex: UInt32

    public let raw: Data
    public let chainCode: Data

    init(raw: Data, chainCode: Data, network: Network = .testnet, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.network = network
        self.raw = raw
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }

    public func extended() -> String {
        var data = Data()
        data += network.xpubkey.bigEndian
        data += depth.littleEndian
        data += fingerprint.littleEndian
        data += childIndex.littleEndian
        data += chainCode
        data += raw
        let checksum = Crypto.sha256sha256(data).prefix(4)
        return Base58.encode(data + checksum)
    }

    public func publicKey() -> PublicKey {
        return PublicKey(bytes: raw, network: network)
    }

    public func derived(at index: UInt32) throws -> HDPublicKey {
        // As we use explicit parameter "hardened", do not allow higher bit set.
        if (0x80000000 & index) != 0 {
            fatalError("invalid child index")
        }
        guard let derivedKey = _HDKey(privateKey: nil, publicKey: raw, chainCode: chainCode, depth: depth, fingerprint: fingerprint, childIndex: childIndex).derived(at: index, hardened: false) else {
            throw DerivationError.derivationFailed
        }
        return HDPublicKey(raw: derivedKey.publicKey!, chainCode: derivedKey.chainCode, network: network, depth: derivedKey.depth, fingerprint: derivedKey.fingerprint, childIndex: derivedKey.childIndex)
    }
}

extension HDPublicKey: CustomStringConvertible {
    public var description: String {
        return extended()
    }
}
#if os(iOS) || os(tvOS) || os(watchOS)
extension HDPublicKey: QRCodeConvertible {}
#endif
