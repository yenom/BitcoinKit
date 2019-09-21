//
//  FeeCalculator.swift
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

public struct FeeCalculator {
    /// Calclate minimum transaction output amount that will be accepted by full nodes
    /// Check here  : https://github.com/Bitcoin-ABC/bitcoin-abc/blob/1da1ddd10d3a52de49fcf3b399917cfbc28ae8d6/src/test/transaction_tests.cpp#L641
    public static func calculateDust(feePerByte: UInt64) -> UInt64 {
        return 3 * 182 * feePerByte
    }

    /// Calculate fee
    // txin(P2PKH) : 148 bytes
    // txout(P2PKH) : 34 bytes
    // cf. txin(P2SH) : cannot be decided
    // cf. txout(P2SH) : 32 bytes
    // cf. txout(OP_RETURN + String) : Roundup([#Characters]/32) + [#Characters] + 11 bytes
    public static func calculateFee(inputs: UInt64, outputs: UInt64, feePerByte: UInt64) -> UInt64 {
        guard inputs > 0 else {
            return 0
        }
        let txByteSize: UInt64 = (inputs * 148) + (outputs * 34) + 10
        return txByteSize * feePerByte
    }

    /// Calculate fee per single input (Not including other inputs, outputs and tx of itself)
    public static func calculateSingleInputFee(feePerByte: UInt64) -> UInt64 {
        return 148 * feePerByte
    }
}
