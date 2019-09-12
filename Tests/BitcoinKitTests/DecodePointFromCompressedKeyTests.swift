//
//  DecodePointFromCompressedKeyTests.swift
//  BitcoinKitTests
//
//  Created by Alexander Cyon on 2019-03-22.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import Foundation
@testable import BitcoinKit
import XCTest

class DecodePointTests: XCTestCase {
    func testPointDecoding() {
        do {
            let wifUncompressed = "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v"
            let wifCompresssed  = "L2r8WPXNgQ79rBdyxjdscd5HHr7BaD9P8Xov7NWZ9pVNw12TFSDZ"
            let privateKeyFromUncompressed = try PrivateKey(wif: wifUncompressed)
            let publicKeyUncompressed = privateKeyFromUncompressed.publicKey()
            XCTAssertFalse(publicKeyUncompressed.isCompressed)

            let decodedFromUncompressed: PointOnCurve = try PointOnCurve.decodePointFromPublicKey(publicKeyUncompressed)
            let expectedY = "ccfca71eff2101ad68238112e7585110e0f2c32d345225985356dc7cab8fdcc9"
            XCTAssertEqual(decodedFromUncompressed.y.data.hex, expectedY)

            let privateKeyFromCompressed = try PrivateKey(wif: wifCompresssed)
            let publicKeyCompressed = privateKeyFromCompressed.publicKey()
            XCTAssertTrue(publicKeyCompressed.isCompressed)

            let decodedFromCompressed: PointOnCurve = try PointOnCurve.decodePointFromPublicKey(publicKeyCompressed)
            XCTAssertEqual(decodedFromCompressed.y.data.hex, expectedY)
            XCTAssertEqual(decodedFromCompressed.y.data.hex, decodedFromUncompressed.y.data.hex)

        } catch {
            XCTFail("Error: \(error)")
        }
    }
}
