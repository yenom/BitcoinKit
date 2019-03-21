//
//  PointOnCurve.swift
//  BitcoinKit
//
//  Created by Alexander Cyon on 2019-03-21.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import Foundation

public struct PointOnCurve {

    public let x: Scalar32Bytes
    public let y: Scalar32Bytes

    public init(x: Scalar32Bytes, y: Scalar32Bytes) {
        self.x = x
        self.y = y
    }
}

public extension PointOnCurve {

    #if BitcoinKitXcode
    public enum Error: Swift.Error {
        case multiplicationResultedInTooFewBytes(expected: Int, butGot: Int)
    }
    #else
    public enum Error: Swift.Error {
        case pointMultiplicationNotSuported
    }
    #endif

    init(x xData: Data, y yData: Data) throws {
        let x = try Scalar32Bytes(data: xData)
        let y = try Scalar32Bytes(data: yData)
        self.init(x: x, y: y)
    }

    func multiplyBy(scalar: Scalar32Bytes) throws -> PointOnCurve {
        #if BitcoinKitXcode
        let xAndY = _EllipticCurve.multiplyECPointX(x.data, andECPointY: y.data, withScalar: scalar.data)
        let expectedByteCount = Scalar32Bytes.expectedByteCount * 2
        guard xAndY.count == expectedByteCount else {
            throw Error.multiplicationResultedInTooFewBytes(expected: expectedByteCount, butGot: xAndY.count)
        }
        let resultX = xAndY.prefix(Scalar32Bytes.expectedByteCount)
        let resultY = xAndY.suffix(Scalar32Bytes.expectedByteCount)
        return try PointOnCurve(x: resultX, y: resultY)
        #else
        throw Error.pointMultiplicationNotSuported
        #endif
    }

    func multiplyBy(privateKey: PrivateKey) throws -> PointOnCurve {
        return try multiplyBy(scalar: privateKey.data)
    }

    func multiplyBy(scalar scalarData: Data) throws -> PointOnCurve {
        let scalar = try Scalar32Bytes(data: scalarData)
        return try multiplyBy(scalar: scalar)
    }
}
