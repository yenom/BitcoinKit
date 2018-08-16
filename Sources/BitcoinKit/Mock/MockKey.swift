//
//  MockKey.swift
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

public class MockKey {
    public static let keyA: MockKey = MockKey(wif: "L1WFAgk5LxC5NLfuTeADvJ5nm3ooV3cKei5Yi9LJ8ENDfGMBZjdW")
    public static let keyB: MockKey = MockKey(wif: "L1hpUWE7R8NsYcREtS9DJPdvnjSRK7X8fatvhH6mStiXxvGTLkdi")
    public static let keyC: MockKey = MockKey(wif: "KxHkyFWVPKZE9ZrYpNmRhfLFxr6TYwXELvcSTdMtZKMzZm95e7KR")
    public static let keyD: MockKey = MockKey(wif: "L31xG1KVupuVJJ6Fc6VzorCr9FaZz7TBQx7saAMBmdjTK8oL3yzB")

    private var wif: String!
    public var privkey: PrivateKey {
        return try! PrivateKey(wif: wif)
    }
    public var pubkey: PublicKey {
        return privkey.publicKey()
    }
    public var pubkeyHash: Data {
        return pubkey.pubkeyHash
    }

    private init(wif: String) {
        self.wif = wif
    }
}

extension MockKey: CustomStringConvertible {
    public var description: String {
        switch wif {
        case "L1WFAgk5LxC5NLfuTeADvJ5nm3ooV3cKei5Yi9LJ8ENDfGMBZjdW":
            return "keyA"
        case "L1hpUWE7R8NsYcREtS9DJPdvnjSRK7X8fatvhH6mStiXxvGTLkdi":
            return "keyB"
        case "KxHkyFWVPKZE9ZrYpNmRhfLFxr6TYwXELvcSTdMtZKMzZm95e7KR":
            return "keyC"
        case "L31xG1KVupuVJJ6Fc6VzorCr9FaZz7TBQx7saAMBmdjTK8oL3yzB":
            return "keyD"
        default:
            return "UnknownKey"
        }
    }
}

extension MockKey: Equatable {
    public static func == (lhs: MockKey, rhs: MockKey) -> Bool {
        return lhs.wif == rhs.wif
    }
}
