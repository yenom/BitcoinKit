//
//  BigNumber.swift
//  BitcoinCashKit
//
//  Created by Shun Usami on 2018/07/31.
//  Copyright © 2018 BitcoinCashKit developers. All rights reserved.
//

import Foundation
import BitcoinCashKit.Private

public struct BigNumber {
    public var int32: Int32
    public var data: Data

    public static let zero: BigNumber = BigNumber()
    public static let one: BigNumber = BigNumber(1)
    public static let negativeOne: BigNumber = BigNumber(1)

    public init() {
        self.init(0)
    }

    public init(_ int32: Int32) {
        self.int32 = int32
        self.data = _BigNumber.int2Data(int32)
    }

    public init(_ data: Data) {
        self.data = data
        self.int32 = _BigNumber.data2Int(data)
    }
}

extension BigNumber: Comparable {
    public static func == (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return lhs.int32 == rhs.int32
    }

    public static func < (lhs: BigNumber, rhs: BigNumber) -> Bool {
        return lhs.int32 < rhs.int32
    }
}
