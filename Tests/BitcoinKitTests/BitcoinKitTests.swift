//
//  BitcoinKitTests.swift
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

class BitcoinKitTests: XCTestCase {
    func testConvertIP() {
        let ipv6Address = "2001:0db8:1234:5678:90ab:cdef:0000:0000"
        XCTAssertEqual(ipv6(from: Data(hex: ipv6Address.split(separator: ":").joined())!), ipv6Address)

        let ipv4mappedIPv6_1 = "0000:0000:0000:0000:0000:ffff:7f00:0001"
        XCTAssertEqual(ipv6(from: Data(hex: ipv4mappedIPv6_1.split(separator: ":").joined())!), ipv4mappedIPv6_1)
        XCTAssertEqual(ipv4(from: Data(hex: ipv4mappedIPv6_1.split(separator: ":").joined())!), "127.0.0.1")

        let ipv4mappedIPv6_2 = "0000:0000:0000:0000:0000:ffff:a00d:d2cc"
        XCTAssertEqual(ipv6(from: Data(hex: ipv4mappedIPv6_2.split(separator: ":").joined())!), ipv4mappedIPv6_2)
        XCTAssertEqual(ipv4(from: Data(hex: ipv4mappedIPv6_2.split(separator: ":").joined())!), "160.13.210.204")

        let ipv4mappedIPv6Data_1 = pton("::ffff:127.0.0.1")
        XCTAssertEqual(ipv6(from: ipv4mappedIPv6Data_1), "0000:0000:0000:0000:0000:ffff:7f00:0001")
        XCTAssertEqual(ipv4(from: ipv4mappedIPv6Data_1), "127.0.0.1")

        let ipv4mappedIPv6Data_2 = pton("2001:0db8:1234:5678:90ab:cdef:0000:0000")
        XCTAssertEqual(ipv6(from: ipv4mappedIPv6Data_2), "2001:0db8:1234:5678:90ab:cdef:0000:0000")
    }
}
