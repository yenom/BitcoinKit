//
//  PointMultiplicationTests.swift
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
import XCTest
@testable import BitcoinKit

class PointMultiplicationTests: XCTestCase {
    func testPointMultiplication() {
        let gX = Data([
            0x79, 0xBE, 0x66, 0x7E, 0xF9, 0xDC, 0xBB, 0xAC,
            0x55, 0xA0, 0x62, 0x95, 0xCE, 0x87, 0x0B, 0x07,
            0x02, 0x9B, 0xFC, 0xDB, 0x2D, 0xCE, 0x28, 0xD9,
            0x59, 0xF2, 0x81, 0x5B, 0x16, 0xF8, 0x17, 0x98
        ])
        
        let gY = Data([
            0x48, 0x3A, 0xDA, 0x77, 0x26, 0xA3, 0xC4, 0x65,
            0x5D, 0xA4, 0xFB, 0xFC, 0x0E, 0x11, 0x08, 0xA8,
            0xFD, 0x17, 0xB4, 0x48, 0xA6, 0x85, 0x54, 0x19,
            0x9C, 0x47, 0xD0, 0x8F, 0xFB, 0x10, 0xD4, 0xB8
        ])
        
        let curveOrderPlusOne = Data([
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE,
            0xBA, 0xAE, 0xDC, 0xE6, 0xAF, 0x48, 0xA0, 0x3B,
            0xBF, 0xD2, 0x5E, 0x8C, 0xD0, 0x36, 0x41, 0x42
        ])
        
        let one = Data([
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01
        ])
        
        XCTAssertEqual(gX.hex, "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798")
        XCTAssertEqual(gY.hex, "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8")
        XCTAssertEqual(curveOrderPlusOne.hex, "fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364142")
        
        do {
            let privateKey = try PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
            let publicKey = privateKey.publicKey()
            XCTAssertEqual(privateKey.data.hex, "a7ec27c206a68e33f53d6a35f284c748e0874ca2f0ea56eca6eb7668db0fe805")
            XCTAssertEqual(privateKey.description, "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
            XCTAssertEqual(publicKey.description, "045d21e7a118c479a007d45401bdbd06e3f9814ad5bbbbc5cec17f19029a060903ccfca71eff2101ad68238112e7585110e0f2c32d345225985356dc7cab8fdcc9")
            
            // test point multiplication
            
            // with some private key
            let g = try PointOnCurve(x: gX, y: gY)
            let publicKeyPoint = try g.multiplyBy(privateKey: privateKey)
            
            XCTAssertEqual(publicKeyPoint.x.data.hex, "5d21e7a118c479a007d45401bdbd06e3f9814ad5bbbbc5cec17f19029a060903")
            XCTAssertEqual(publicKeyPoint.y.data.hex, "ccfca71eff2101ad68238112e7585110e0f2c32d345225985356dc7cab8fdcc9")
            
            // with order plus 1
            let pointOrderPlus1 = try g.multiplyBy(scalar: curveOrderPlusOne)
            XCTAssertEqual(pointOrderPlus1.x.data.hex, "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798")
            XCTAssertEqual(pointOrderPlus1.y.data.hex, "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8")
            let pointOne = try g.multiplyBy(scalar: one)
            XCTAssertEqual(pointOrderPlus1.x.data.hex, pointOne.x.data.hex)
            XCTAssertEqual(pointOrderPlus1.y.data.hex, pointOne.y.data.hex)
        } catch {
            XCTFail("error: \(error)")
        }
    }

}
