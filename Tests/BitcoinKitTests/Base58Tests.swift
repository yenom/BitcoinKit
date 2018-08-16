//
//  Base58Tests.swift
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

import XCTest
@testable import BitcoinKit

class Base58Tests: XCTestCase {
    func testBase58_1() {
        XCTAssertEqual(Base58.decode("1EVEDmVcV7iPvTkaw2gk89yVcCzPzaS6B7")!.hex, "0093f051563b089897cb430602a7c35cd93b3cc8e9dfac9a96")
        XCTAssertEqual(Base58.decode("11ujQcjgoMNmbmcBkk8CXLWQy8ZerMtuN")!.hex, "00002c048b88f56727538eadb2a81cfc350355ee4c466740d9")
        XCTAssertEqual(Base58.decode("111oeV7wjVNCQttqY63jLFsg817aMEmTw")!.hex, "000000abdda9e604c965f5a2fe8c082b14fafecdc39102f5b2")
    }

    func testBase58_2() {
        do {
            let original = Data(hex: "00010966776006953D5567439E5E39F86A0D273BEED61967F6")!

            let encoded = Base58.encode(original)
            XCTAssertEqual(encoded, "16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM")

            let decoded = Base58.decode(encoded)!
            XCTAssertEqual(decoded.hex, original.hex)
        }
    }

    func testAll() {
        XCTAssertNil(Base58.decode(""))
        XCTAssertNil(Base58.decode(" "))
        XCTAssertNil(Base58.decode("lO"))
        XCTAssertNil(Base58.decode("l"))
        XCTAssertNil(Base58.decode("O"))
        XCTAssertNil(Base58.decode("öまи"))
        
        HexEncodesToBase58(hex: "61", base58: "2g")
        HexEncodesToBase58(hex: "626262", base58: "a3gV")
        HexEncodesToBase58(hex: "636363", base58: "aPEr")
        HexEncodesToBase58(hex: "73696d706c792061206c6f6e6720737472696e67", base58: "2cFupjhnEsSn59qHXstmK2ffpLv2")
        HexEncodesToBase58(hex: "00eb15231dfceb60925886b67d065299925915aeb172c06647", base58: "1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L")
        HexEncodesToBase58(hex: "516b6fcd0f", base58: "ABnLTmg")
        HexEncodesToBase58(hex: "bf4f89001e670274dd", base58: "3SEo3LWLoPntC")
        HexEncodesToBase58(hex: "572e4794", base58: "3EFU7m")
        HexEncodesToBase58(hex: "ecac89cad93923c02321", base58: "EJDM8drfXA6uyA")
        HexEncodesToBase58(hex: "10c8511e", base58: "Rt5zm")
        HexEncodesToBase58(hex: "00000000000000000000", base58: "1111111111")
    }
    
    func HexEncodesToBase58(hex: String, base58: String) {
        //Encode
        let data = Data(hex: hex)!
        XCTAssertEqual(Base58.encode(data), base58)
        //Decode
        XCTAssertEqual(Base58.decode(base58)!.hex, hex)
    }
}
