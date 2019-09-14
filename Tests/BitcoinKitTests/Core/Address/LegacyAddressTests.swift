//
//  LegacyAddressTests.swift
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

class LegacyAddressTests: XCTestCase {
    func testAddress() {
        // Mainnet
        do {
            let privateKey = try! PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
            let publicKey = privateKey.publicKey()

            let address1 = publicKey.toLegacy()
            XCTAssertEqual("\(address1)", address1.base58)

            let address2 = try? LegacyAddress("1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
            XCTAssertNotNil(address2)
            XCTAssertEqual(address2?.cashaddr, "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
            XCTAssertEqual(address1, address2)

            do {
                _ = try LegacyAddress("175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W")
                XCTFail("Should throw invalid checksum error.")
            } catch AddressError.invalid {
                // Success
            } catch {
                XCTFail("Should throw invalid checksum error.")
            }
        }

        // Testnet
        do {
            let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
            let publicKey = privateKey.publicKey()

            let address1 = publicKey.toLegacy()
            XCTAssertEqual("\(address1)", address1.base58)

            let address2 = try? LegacyAddress("mjNkq5ycsAfY9Vybo9jG8wbkC5mbpo4xgC")
            XCTAssertNotNil(address2)
            XCTAssertEqual(address2?.cashaddr, "bchtest:qq498xkl67h0espwqxttfn8hdt4g3g05wqtqeyg993")
            XCTAssertEqual(address1, address2)
        }
    }
}
