//
//  PrivateKeyTests.swift
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

import XCTest
@testable import BitcoinKit

class PrivateKeyTests: XCTestCase {
    func testGenerateKeyPair() {
        let privateKey = PrivateKey(network: .testnet)
        let publicKey = privateKey.publicKey()

        XCTAssertNotNil(privateKey)
        XCTAssertNotNil(publicKey)

        let wif = privateKey.toWIF()
        let fromWIF = try? PrivateKey(wif: wif)
        XCTAssertEqual(privateKey, fromWIF)
    }

    func testWIF() {
        // Mainnet
        do {
            let privateKey = try? PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
            let publicKey = privateKey?.publicKey()

            XCTAssertNotNil(privateKey)
            XCTAssertNotNil(publicKey)

            XCTAssertEqual(privateKey?.network, Network.mainnet)

            XCTAssertEqual(privateKey?.data.hex, "a7ec27c206a68e33f53d6a35f284c748e0874ca2f0ea56eca6eb7668db0fe805")
            XCTAssertEqual(privateKey?.description, "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
            XCTAssertEqual(publicKey?.description, "045d21e7a118c479a007d45401bdbd06e3f9814ad5bbbbc5cec17f19029a060903ccfca71eff2101ad68238112e7585110e0f2c32d345225985356dc7cab8fdcc9")
        }

        // Testnet
        do {
            let privateKey = try? PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
            let publicKey = privateKey?.publicKey()

            XCTAssertNotNil(privateKey)
            XCTAssertNotNil(publicKey)

            XCTAssertEqual(privateKey?.network, Network.testnet)

            XCTAssertEqual(privateKey?.data.hex, "a2359719d3dc9f1539c593e477dc9d57b9653a18e7c94299d87a95ed13525eae")
            XCTAssertEqual(privateKey?.description, "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
            XCTAssertEqual(publicKey?.description, "047e000cc16c9a4d38cb1572b9dc34c1452626aa170b46150d0e806be1b42517f0832c8a58f543128083ffb8632bae94dd5f3e1e89fad0a17f64ed8bbbb90b5753")
        }
    }
}
