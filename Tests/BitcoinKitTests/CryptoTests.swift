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

class CryptoTests: XCTestCase {
    func testSHA256() {
        /* Usually, when a hash is computed within bitcoin, it is computed twice.
         Most of the time SHA-256 hashes are used, however RIPEMD-160 is also used when a shorter hash is desirable
         (for example when creating a bitcoin address).

         https://en.bitcoin.it/wiki/Protocol_documentation#Hashes
         */
        XCTAssertEqual(Crypto.sha256("hello".data(using: .ascii)!).hex, "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
        XCTAssertEqual(Crypto.sha256sha256("hello".data(using: .ascii)!).hex, "9595c9df90075148eb06860365df33584b75bff782a510c6cd4883a419833d50")
    }

    func testSHA256RIPEMD160() {
        XCTAssertEqual(Crypto.sha256ripemd160("hello".data(using: .ascii)!).hex, "b6a9c8c230722b7c748331a8b450f05566dc7d0f")
    }

    func testSign() {
        let msg = Data(hex: "52204d20fd0131ae1afd173fd80a3a746d2dcc0cddced8c9dc3d61cc7ab6e966")!
        let pk = Data(hex: "16f243e962c59e71e54189e67e66cf2440a1334514c09c00ddcc21632bac9808")!
        let privateKey = PrivateKey(data: pk)

        let signature = try? Crypto.sign(msg, privateKey: privateKey)

        XCTAssertNotNil(signature)
        XCTAssertEqual(signature?.hex, "3044022055f4b20035cbb2e85b7a04a0874c80d5822758f4e47a9a69db04b29f8b218f920220491e6a13296cfe2186da3a3ca565a179def3808b12d184553a8e3acfe1467273")
    }
}
