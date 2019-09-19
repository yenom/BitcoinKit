//
//  UnspentTransactionSelector.swift
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

/// Helper model that selects a set of unspent transactions to spend
/// ```
/// // Select a unspent transactions to spend
/// let selected = UnspentTransactionSelector.select(from: unspentTransactions, targetValue: 1000, feePerByte: 1)
/// ```
public struct UnspentTransactionSelector {
    public static func select(from unspentTransactions: [UnspentTransaction], targetValue: UInt64, feePerByte: UInt64) -> [UnspentTransaction] {
        let dustValue: UInt64 = FeeCalculator.calculateDust(feePerByte: feePerByte)

        // if target value is dust, return empty array
        guard targetValue >= dustValue else {
            return []
        }

        // definitions for the following caluculation
        let doubleTargetValue: UInt64 = targetValue * 2
        var numOutputs = 2 // if allow multiple output, it will be changed.
        var numInputs = 2
        var fee: UInt64 {
            return FeeCalculator.calculateFee(inputs: UInt64(numInputs), outputs: UInt64(numOutputs), feePerByte: feePerByte)
        }
        var targetWithFee: UInt64 {
            return targetValue + fee
        }
        var targetWithFeeAndDust: UInt64 {
            return targetWithFee + dustValue
        }

        // Filter too small utxos and sort ascending order
        let singleInputFee: UInt64 = FeeCalculator.calculateSingleInputFee(feePerByte: feePerByte)
        let availableUnspentTransactions: [UnspentTransaction] = unspentTransactions
            .filter { $0.output.value > singleInputFee }
            .sorted(by: { $0.output.value < $1.output.value })

        // Maximum available amount of utxos should be greater than targetValue
        let feeToSpendAll: UInt64 = FeeCalculator.calculateFee(inputs: UInt64(availableUnspentTransactions.count), outputs: 1, feePerByte: feePerByte)
        let availableMax: UInt64 = availableUnspentTransactions.sum() - feeToSpendAll
        guard availableMax >= targetValue else {
            return availableUnspentTransactions
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
            for numTx in (1...availableUnspentTransactions.count) {
                numInputs = numTx
                let nOutputsSlices = availableUnspentTransactions.slices(of: numInputs)
                var nOutputsInRange = nOutputsSlices.filter { $0.sum() >= targetWithFeeAndDust }
                guard !nOutputsInRange.isEmpty else {
                    continue
                }
                nOutputsInRange.sort { distFrom2x($0.sum()) < distFrom2x($1.sum()) }
                if let nOutputs = nOutputsInRange.first {
                    return Array(nOutputs)
                }
            }
        }

        // 2. If not, find a combination of outputs that may produce dust change.
        numOutputs = 1
        txDiscardDust:do {
            for numTx in (1...availableUnspentTransactions.count) {
                numInputs = numTx
                let nOutputsSlices = availableUnspentTransactions.slices(of: numInputs)
                let nOutputsInRange = nOutputsSlices.filter {
                    return $0.sum() >= targetWithFee
                }
                if let nOutputs = nOutputsInRange.first {
                    return Array(nOutputs)
                }
            }
        }

        // This can't be called
        return availableUnspentTransactions
    }
}

internal extension Sequence where Element == UnspentTransaction {
    func sum() -> UInt64 {
        return self.map { $0.output.value }.reduce(0, +)
    }
}

private extension Array {
    // Slice Array
    // [0,1,2,3,4,5,6,7,8,9].slices(of: 3)
    // >
    // [[0, 1, 2], [1, 2, 3], [2, 3, 4], [3, 4, 5], [4, 5, 6], [5, 6, 7], [6, 7, 8], [7, 8, 9]]
    func slices(of size: Int) -> [ArraySlice<Element>] {
        return (0...count - size).map { self[$0..<$0 + size] }
    }
}
