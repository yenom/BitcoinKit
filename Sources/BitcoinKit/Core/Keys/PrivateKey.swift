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
    public let shouldCompressPublicKey: Bool

    /// The "designated" initializer of the `PrivateKey` struct, initialized from a scalar (represented as `Data` in lack of `BigInt` type). This scalar has to be within
    /// the correct bounds, thus a validation check is done, why this initializer is throwing.
    ///
    /// - Parameter data: The private key scalar, represented as `Data` ( in lack of `BigInt` type), has to a value in range `0 < key < Secp256k1.orderOfCurve`
    /// - Parameter network: Which network used
    /// - Parameter shouldCompressPublicKey: Wether to compress public key or not.
    public init(data: Data, network: Network = .testnet, shouldCompressPublicKey: Bool = true) throws {

        // Ensure private key data is on correct bounds.
        self.data = try PrivateKey.validate(privateKeyCandidate: data)

        self.network = network
        self.shouldCompressPublicKey = shouldCompressPublicKey
    }
}

// MARK: - Convenience Init
public extension PrivateKey {

    /// Generates a new PrivateKey from securely generated entropy using Apple's `SecRandomCopyBytes` generator.
    init(network: Network = .testnet, shouldCompressPublicKey: Bool = true) {

        let count = 32
        var key: Data!
        repeat {
            guard
                let randomBytes = try? securelyGenerateBytes(count: count),
                let privateKeyData = try? PrivateKey.validate(privateKeyCandidate: randomBytes)
                else { continue }
            key = privateKeyData
        } while key == nil

        do {
            try self.init(data: key, network: network, shouldCompressPublicKey: shouldCompressPublicKey)
        } catch {
            fatalError("Unexpected error: \(error), should always be able to generate new private key, implementation of this init is incorrect.")
        }
    }

    /// From `Wallet Import Format` (a.k.a. "WIF")
    init(wif: String) throws {
        let invalidFormatError = Error.importError(.invalidFormat)
        guard let decoded = Base58.decode(wif) else {
            throw invalidFormatError
        }
        let checksumDropped = decoded.prefix(decoded.count - 4)
        guard checksumDropped.count == (1 + 32) || checksumDropped.count == (1 + 32 + 1) else {
            throw invalidFormatError
        }

        func networkFrom(addressPrefixByte: UInt8) throws -> Network {
            switch addressPrefixByte {
            case Network.mainnet.privatekey:
                return .mainnet
            case Network.testnet.privatekey:
                return .testnet
            default:
                throw invalidFormatError
            }
        }

        let h = Crypto.sha256sha256(checksumDropped)
        let calculatedChecksum = h.prefix(4)
        let originalChecksum = decoded.suffix(4)
        guard calculatedChecksum == originalChecksum else {
            throw invalidFormatError
        }

        // The life is not always easy. Somehow some people added one extra byte to a private key in Base58 to
        // let us know that the resulting public key must be compressed.
        let shouldCompressPublicKey = (checksumDropped.count == (1 + 32 + 1))

        // Private key itself is always 32 bytes.
        let privateKeyData = checksumDropped.dropFirst().prefix(32)

        let network = try networkFrom(addressPrefixByte: checksumDropped[0])

        try self.init(
            data: privateKeyData,
            network: network,
            shouldCompressPublicKey: shouldCompressPublicKey
        )
    }
}

// MARK: - Public
public extension PrivateKey {
    /// Checks if `privateKeyCandidate` is greater than or equal to max value
    @discardableResult
    static func validate(privateKeyCandidate: Data) throws -> Data {
        if privateKeyCandidate.allSatisfy({ $0 == 0 }) {
            throw Error.mustBeGreaterThanZero
        }

        let curveOrderMinusOne: Data = {
            var tmp = Curve.Secp256k1.order
            tmp[tmp.count - 1] = tmp.last! - 1
            return tmp
        }()

        for (index, byte) in privateKeyCandidate.enumerated() {
            if byte < curveOrderMinusOne[index] {
                // strictly smaller than the order, thus valid!
                return privateKeyCandidate
            }
            if byte > curveOrderMinusOne[index] {
                throw Error.mustBeSmallerThanCurveOrder
            }
        }

        // Private key scalar (represented as byte) is within the correct bounds.
        return privateKeyCandidate
    }

    func publicKeyPoint() throws -> PointOnCurve {
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

    func publicKey() -> PublicKey {
        return PublicKey(bytes: computePublicKeyData(), network: network)
    }

    func toWIF() -> String {
        var payload = Data([network.privatekey]) + data
        if shouldCompressPublicKey {
            // Add extra byte 0x01 in the end.
            payload += Int8(1)
        }
        let checksum = Crypto.sha256sha256(payload).prefix(4)
        return Base58.encode(payload + checksum)
    }

    func sign(_ data: Data) -> Data {
        return try! Crypto.sign(data, privateKey: self)
    }

    @available(*, unavailable, message: "Use SignatureHashHelper and sign(_ data: Data) method instead")
    func sign(_ tx: Transaction, utxoToSign: UnspentTransaction, hashType: SighashType, inputIndex: Int = 0) -> Data {
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

// MARK: - Error
public typealias PrivateKeyError = PrivateKey.Error
public extension PrivateKey {

    enum Error: Swift.Error, Equatable {
        case mustBeGreaterThanZero
        case mustBeSmallerThanCurveOrder
        indirect case importError(ImportError)
    }

    enum ImportError: Swift.Error, Equatable {
        case invalidFormat
    }
}

// MARK: - Private
private extension PrivateKey {

    func computePublicKeyData() -> Data {
        return _SwiftKey.computePublicKey(fromPrivateKey: data, compression: shouldCompressPublicKey)
    }
}
