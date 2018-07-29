//
//  PrivateKey.swift
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

public struct PrivateKey {
    let raw: Data
    public let network: Network
    public let isPublicKeyCompressed: Bool

    // QUESTION: これランダムに生成する場合かな？
    public init(network: Network = .testnet, isPublicKeyCompressed: Bool = true) {
        self.network = network
        self.isPublicKeyCompressed = isPublicKeyCompressed

        // Check if vch is greater than or equal to max value
        func check(_ vch: [UInt8]) -> Bool {
            let max: [UInt8] = [
                0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE,
                0xBA, 0xAE, 0xDC, 0xE6, 0xAF, 0x48, 0xA0, 0x3B,
                0xBF, 0xD2, 0x5E, 0x8C, 0xD0, 0x36, 0x41, 0x40
            ]
            var fIsZero = true
            for byte in vch where byte != 0 {
                fIsZero = false
                break
            }
            if fIsZero {
                return false
            }
            for (index, byte) in vch.enumerated() {
                if byte < max[index] {
                    return true
                }
                if byte > max[index] {
                    return false
                }
            }
            return true
        }

        let count = 32
        var key = Data(count: count)
        var status: Int32 = 0
        repeat {
            status = key.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, count, $0) }
        } while (status != 0 || !check([UInt8](key)))

        self.raw = key
    }

    public init(wif: String) throws {
        guard let decoded = Base58.decode(wif) else {
            throw PrivateKeyError.invalidFormat
        }
        let checksumDropped = decoded.prefix(decoded.count - 4)
        guard checksumDropped.count == (1 + 32) || checksumDropped.count == (1 + 32 + 1) else {
            throw PrivateKeyError.invalidFormat
        }

        let addressPrefix = checksumDropped[0]
        switch addressPrefix {
        case Network.mainnet.privatekey:
            network = .mainnet
        case Network.testnet.privatekey:
            network = .testnet
        default:
            throw PrivateKeyError.invalidFormat
        }

        let h = Crypto.sha256sha256(checksumDropped)
        let calculatedChecksum = h.prefix(4)
        let originalChecksum = decoded.suffix(4)
        guard calculatedChecksum == originalChecksum else {
            throw PrivateKeyError.invalidFormat
        }

        // The life is not always easy. Somehow some people added one extra byte to a private key in Base58 to
        // let us know that the resulting public key must be compressed.
        self.isPublicKeyCompressed = (checksumDropped.count == (1 + 32 + 1))

        // Private key itself is always 32 bytes.
        raw = checksumDropped.dropFirst().prefix(32)
    }

    public init(data: Data, network: Network = .testnet, isPublicKeyCompressed: Bool = true) {
        raw = data
        self.network = network
        self.isPublicKeyCompressed = isPublicKeyCompressed
    }

    public func publicKey() -> PublicKey {
        return PublicKey(privateKey: self)
    }

    public func toWIF() -> String {
        var data = Data([network.privatekey]) + raw
        if isPublicKeyCompressed {
            // Add extra byte 0x01 in the end.
            data += Int8(1)
        }
        let checksum = Crypto.sha256sha256(data).prefix(4)
        return Base58.encode(data + checksum)
    }
}

extension PrivateKey: Equatable {
    // swiftlint:disable:next operator_whitespace
    public static func ==(lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        return lhs.network == rhs.network && lhs.raw == rhs.raw
    }
}

extension PrivateKey: CustomStringConvertible {
    public var description: String {
        return raw.hex
    }
}

public enum PrivateKeyError: Error {
    case invalidFormat
}
