//
//  SerializationTests.swift
//  BitcoinKitTests
//
//  Created by Shun Usami on 2018/09/25.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import XCTest
@testable import BitcoinKit

class SerializationTests: XCTestCase {

    func testDataToInt32() {
        for _ in 0..<10 {
            for i in 0...255 {
                let data: Data = Data([UInt8(i)])
                let intValue: Int32 = data.to(type: Int32.self)
                XCTAssertEqual(intValue, Int32(i), "\(i) time")
            }
        }
    }

}
