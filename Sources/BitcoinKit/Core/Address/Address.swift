//
//  Address.swift
// 
//  Copyright © 2019 BitcoinKit developers
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

public protocol Address: CustomStringConvertible {
    var network: Network { get }
    var hashType: BitcoinAddress.HashType { get }
    var data: Data { get }
    var legacy: String { get }
    var cashaddr: String { get }
}

extension Address {
    @available(*, deprecated, message: "Always returns nil. If you need public key with address, please use PublicKey instead.")
    public var publicKey: Data? {
        return nil
    }

    @available(*, deprecated, renamed: "legacy")
    public var base58: String {
        return legacy
    }

    @available(*, deprecated, renamed: "hashType")
    public var type: BitcoinAddress.HashType {
        return hashType
    }
}
