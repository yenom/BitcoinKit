//
//  PrivateKey.swift
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

public struct PrivateKey {
    @available(*, deprecated, renamed: "data")
    public var raw: Data { return data }
    public let data: Data
    public let network: Network
    public let isPublicKeyCompressed: Bool

    public init(network: Network = .testnetBCH, isPublicKeyCompressed: Bool = true) {
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
            status = key.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, count, $0.baseAddress.unsafelyUnwrapped) }
        } while (status != 0 || !check([UInt8](key)))

        self.data = key
    }

    public init(wif: String) throws {
        guard var payload = Base58Check.decode(wif),
            (payload.count == (1 + 32) || payload.count == (1 + 32 + 1)) else {
            throw PrivateKeyError.invalidFormat
        }

        let addressPrefix = payload.popFirst()!
        switch addressPrefix {
        case Network.mainnetBCH.privatekey:
            network = .mainnetBCH
        case Network.testnetBCH.privatekey:
            network = .testnetBCH
        default:
            throw PrivateKeyError.invalidFormat
        }

        // The life is not always easy. Somehow some people added one extra byte to a private key in Base58 to
        // let us know that the resulting public key must be compressed.
        self.isPublicKeyCompressed = (payload.count == (32 + 1))

        // Private key itself is always 32 bytes.
        data = payload.prefix(32)
    }

    public init(data: Data, network: Network = .testnetBCH, isPublicKeyCompressed: Bool = true) {
        self.data = data
        self.network = network
        self.isPublicKeyCompressed = isPublicKeyCompressed
    }

    private func computePublicKeyData() -> Data {
        return _SwiftKey.computePublicKey(fromPrivateKey: data, compression: isPublicKeyCompressed)
    }

    public func publicKeyPoint() throws -> PointOnCurve {
        let xAndY: Data = _SwiftKey.computePublicKey(fromPrivateKey: data, compression: false)
        let expectedLengthOfScalar = Scalar32Bytes.expectedByteCount
        let expectedLengthOfKey = expectedLengthOfScalar * 2
        guard xAndY.count == expectedLengthOfKey else {
            fatalError("expected length of key is \(expectedLengthOfKey) bytes, but got: \(xAndY.count)")
        }
        let x = xAndY.prefix(expectedLengthOfScalar)
        let y = xAndY.suffix(expectedLengthOfScalar)
        return try PointOnCurve(x: x, y: y)
    }

    public func publicKey() -> PublicKey {
        return PublicKey(bytes: computePublicKeyData(), network: network)
    }

    public func toWIF() -> String {
        var payload = Data([network.privatekey]) + data
        if isPublicKeyCompressed {
            // Add extra byte 0x01 in the end.
            payload += Int8(1)
        }
        return Base58Check.encode(payload)
    }

    public func sign(_ data: Data) -> Data {
        return try! Crypto.sign(data, privateKey: self)
    }

    @available(*, unavailable, message: "Use SignatureHashHelper and sign(_ data: Data) method instead")
    public func sign(_ tx: Transaction, utxoToSign: UnspentTransaction, hashType: SighashType, inputIndex: Int = 0) -> Data {
        let helper: SignatureHashHelper
        if hashType.hasForkId {
            helper = BCHSignatureHashHelper(hashType: BCHSighashType(rawValue: hashType.uint8)!)
        } else {
            helper = BTCSignatureHashHelper(hashType: BTCSighashType(rawValue: hashType.uint8)!)
        }
        let sighash = helper.createSignatureHash(of: tx, for: utxoToSign.output, inputIndex: inputIndex)
        return try! Crypto.sign(sighash, privateKey: self)
    }
}

extension PrivateKey: Equatable {
    public static func == (lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        return lhs.network == rhs.network && lhs.data == rhs.data
    }
}

extension PrivateKey: CustomStringConvertible {
    public var description: String {
        return toWIF()
    }
}

#if os(iOS) || os(tvOS) || os(watchOS)
extension PrivateKey: QRCodeConvertible {}
#endif

public enum PrivateKeyError: Error {
    case invalidFormat
}
