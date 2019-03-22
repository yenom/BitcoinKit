//
//  Scalar32Bytes.swift
//  BitcoinKit
//
//  Created by Alexander Cyon on 2019-03-21.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import Foundation

public struct Scalar32Bytes {
    public enum Error: Swift.Error {
        case tooManyBytes(expectedCount: Int, butGot: Int)
    }
    public static let expectedByteCount = 32
    public let data: Data
    public init(data: Data) throws {
        let byteCount = data.count
        if byteCount > Scalar32Bytes.expectedByteCount {
            throw Error.tooManyBytes(expectedCount: Scalar32Bytes.expectedByteCount, butGot: byteCount)
        }
        self.data = data
    }
}
