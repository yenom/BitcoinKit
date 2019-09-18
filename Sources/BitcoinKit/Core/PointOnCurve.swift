//
//  PointOnCurve.swift
//
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

public struct PointOnCurve {

    private static let byteForUncompressed: UInt8 = 0x04
    public let x: Scalar32Bytes
    public let y: Scalar32Bytes

    public init(x: Scalar32Bytes, y: Scalar32Bytes) {
        self.x = x
        self.y = y
    }

    init(x xData: Data, y yData: Data) throws {
        let x = try Scalar32Bytes(data: xData)
        let y = try Scalar32Bytes(data: yData)
        self.init(x: x, y: y)
    }
}

public extension PointOnCurve {
    enum Error: Swift.Error {
        case multiplicationResultedInTooFewBytes(expected: Int, butGot: Int)
        case expectedUncompressedPoint
        case publicKeyContainsTooFewBytes(expected: Int, butGot: Int)
    }

    static func decodePointFromPublicKey(_ publicKey: PublicKey) throws -> PointOnCurve {
        let data: Data
        if publicKey.isCompressed {
            data = _EllipticCurve.decodePointOnCurve(forCompressedPublicKey: publicKey.data)
        } else {
            data = publicKey.data
        }
        return try PointOnCurve.decodePointFrom(xAndYPrefixedWithCompressionType: data)
    }

    private static func decodePointFrom(xAndYPrefixedWithCompressionType data: Data) throws -> PointOnCurve {
        var xAndY = data
        guard xAndY[0] == PointOnCurve.byteForUncompressed else {
            throw Error.expectedUncompressedPoint
        }
        xAndY = Data(xAndY.dropFirst())
        let expectedByteCount = Scalar32Bytes.expectedByteCount * 2
        guard xAndY.count == expectedByteCount else {
            throw Error.multiplicationResultedInTooFewBytes(expected: expectedByteCount, butGot: xAndY.count)
        }
        let resultX = xAndY.prefix(Scalar32Bytes.expectedByteCount)
        let resultY = xAndY.suffix(Scalar32Bytes.expectedByteCount)
        return try PointOnCurve(x: resultX, y: resultY)
    }

    func multiplyBy(scalar: Scalar32Bytes) throws -> PointOnCurve {
        let xAndY = _EllipticCurve.multiplyECPointX(x.data, andECPointY: y.data, withScalar: scalar.data)
        return try PointOnCurve.decodePointFrom(xAndYPrefixedWithCompressionType: xAndY)
    }

    func multiplyBy(privateKey: PrivateKey) throws -> PointOnCurve {
        return try multiplyBy(scalar: privateKey.data)
    }

    func multiplyBy(scalar scalarData: Data) throws -> PointOnCurve {
        let scalar = try Scalar32Bytes(data: scalarData)
        return try multiplyBy(scalar: scalar)
    }
}
