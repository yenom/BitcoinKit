//
//  PointOnCurve.swift
//  BitcoinKit
//
//  Created by Alexander Cyon on 2019-03-21.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import Foundation

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

#if BitcoinKitXcode
public extension PointOnCurve {

    public enum Error: Swift.Error {
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
#endif
