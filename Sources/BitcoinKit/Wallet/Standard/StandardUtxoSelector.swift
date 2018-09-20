//
//  StandardUtxoSelector.swift
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

public struct StandardUtxoSelector: UtxoSelector {
    public let feePerByte: UInt64
    public let dustThreshhold: UInt64

    public init(feePerByte: UInt64 = 1, dustThreshhold: UInt64 = 3 * 182) {
        self.feePerByte = feePerByte
        self.dustThreshhold = dustThreshhold
    }

    public func select(from utxos: [UnspentTransaction], targetValue: UInt64) throws -> (utxos: [UnspentTransaction], fee: UInt64) {
        // if target value is zero, fee is zero
        guard targetValue > 0 else {
            return ([], 0)
        }

        // definitions for the following caluculation
        let doubleTargetValue = targetValue * 2
        var numOutputs = 2 // if allow multiple output, it will be changed.
        var numInputs = 2
        var fee: UInt64 {
            return calculateFee(nIn: numInputs, nOut: numOutputs)
        }
        var targetWithFee: UInt64 {
            return targetValue + fee
        }
        var targetWithFeeAndDust: UInt64 {
            return targetWithFee + dustThreshhold
        }

        let sortedUtxos: [UnspentTransaction] = utxos.sorted(by: { $0.output.value < $1.output.value })

        // total values of utxos should be greater than targetValue
        guard sortedUtxos.sum() >= targetValue && !sortedUtxos.isEmpty else {
            throw UtxoSelectError.insufficientFunds
        }

        // difference from 2x targetValue
        func distFrom2x(_ val: UInt64) -> UInt64 {
            if val > doubleTargetValue { return val - doubleTargetValue } else { return doubleTargetValue - val }
        }

        // 1. Find a combination of the fewest outputs that is
        //    (1) bigger than what we need
        //    (2) closer to 2x the amount,
        //    (3) and does not produce dust change.
        txN:do {
            for numTx in (1...sortedUtxos.count) {
                numInputs = numTx
                let nOutputsSlices = sortedUtxos.eachSlices(numInputs)
                var nOutputsInRange = nOutputsSlices.filter { $0.sum() >= targetWithFeeAndDust }
                nOutputsInRange.sort { distFrom2x($0.sum()) < distFrom2x($1.sum()) }
                if let nOutputs = nOutputsInRange.first {
                    return (nOutputs, fee)
                }
            }
        }

        // 2. If not, find a combination of outputs that may produce dust change.
        txDiscardDust:do {
            for numTx in (1...sortedUtxos.count) {
                numInputs = numTx
                let nOutputsSlices = sortedUtxos.eachSlices(numInputs)
                let nOutputsInRange = nOutputsSlices.filter {
                    return $0.sum() >= targetWithFee
                }
                if let nOutputs = nOutputsInRange.first {
                    return (nOutputs, fee)
                }
            }
        }

        throw UtxoSelectError.insufficientFunds
    }

    private func calculateFee(nIn: Int, nOut: Int = 2) -> UInt64 {
        var txsize: Int {
            return ((148 * nIn) + (34 * nOut) + 10)
        }
        return UInt64(txsize) * feePerByte
    }
}

enum UtxoSelectError: Error {
    case insufficientFunds
    case error(String)
}

private extension Array {
    // Slice Array
    // [0,1,2,3,4,5,6,7,8,9].eachSlices(3)
    // >
    // [[0, 1, 2], [1, 2, 3], [2, 3, 4], [3, 4, 5], [4, 5, 6], [5, 6, 7], [6, 7, 8], [7, 8, 9]]
    func eachSlices(_ num: Int) -> [[Element]] {
        let slices = (0...count - num).map { self[$0..<$0 + num].map { $0 } }
        return slices
    }
}
