//
//  UnspentTransactionOutputSelectorTests.swift
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

import XCTest
@testable import BitcoinKit

func buildUnspent(_ value: UInt64) -> UnspentTransaction {
    let outpoint: TransactionOutPoint = TransactionOutPoint(hash: Data(), index: 0)
    let output: TransactionOutput = TransactionOutput(value: value, lockingScript: Data())
    return UnspentTransaction(output: output, outpoint: outpoint)
}

class UnspentTransactionOutputSelectorTests: XCTestCase {
    var utxos: [UnspentTransaction] = []
    
    override func setUp() {
        utxos = []
    }
    
    func testEmptyUtxos() {
        // If utxos are empty, returns empty
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 3000, feePerByte: 1)
        XCTAssertTrue(selected.isEmpty)
    }

    func testTargetValueIsZero() {
        // If targetValue is 0, returns empty
        utxos.append(buildUnspent(1000))
        utxos.append(buildUnspent(2000))
        utxos.append(buildUnspent(3000))
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 0, feePerByte: 1)
        XCTAssertTrue(selected.isEmpty)
    }
    
    func testSingleUtxoCloseToDouble() {
        // 1. Single utxo closest 2x
        utxos.append(buildUnspent(2000))
        utxos.append(buildUnspent(6000))
        utxos.append(buildUnspent(1000))
        utxos.append(buildUnspent(11000))
        utxos.append(buildUnspent(12000))
        
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 5000, feePerByte: 1)
        XCTAssertEqual(selected.count, 1)
        XCTAssertEqual(selected.sum(), 11000)
    }
    
    func testTwoUtxosCloseToDouble() {
        // 3. Two utxos closest to 2x value of target
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(2000))
        utxos.append(buildUnspent(5000))
        
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 4999, feePerByte: 1)
        XCTAssertEqual(selected.count, 2)
        XCTAssertEqual(selected.sum(), 9000)
    }
    
    func testFewestUtxosGreaterThanTarget() {
        // 5. Fewest utxos greater than 1x value of target
        utxos.append(buildUnspent(1000))
        utxos.append(buildUnspent(2000))
        utxos.append(buildUnspent(3000))
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(5000))
        utxos.append(buildUnspent(6000))
        utxos.append(buildUnspent(7000))
        utxos.append(buildUnspent(8000))
        utxos.append(buildUnspent(9000))
        
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 28000, feePerByte: 1)
        XCTAssertEqual(selected.count, 4)
        XCTAssertEqual(selected.sum(), 30000)
        XCTAssertEqual(selected[0].output.value, 6000)
        XCTAssertEqual(selected[1].output.value, 7000)
        XCTAssertEqual(selected[2].output.value, 8000)
        XCTAssertEqual(selected[3].output.value, 9000)
    }
    
    func testInsufficientFund() {
        // 6. Insufficient funds
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(4000))
        
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 15000, feePerByte: 1)
        XCTAssertEqual(selected.count, 3)
        XCTAssertEqual(selected.sum(), 12000)
    }

    func testUtxos1() {
        // Trust/wallet-core: SelectUnpsents1
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(2000))
        utxos.append(buildUnspent(6000))
        utxos.append(buildUnspent(1000))
        utxos.append(buildUnspent(11_000))
        utxos.append(buildUnspent(12_000))
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 5000, feePerByte: 1)
        XCTAssertEqual(selected.count, 1)
        XCTAssertEqual(selected.sum(), 11_000)
    }
    
    func testUtxos2() {
        // Trust/wallet-core: SelectUnpsents2
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(2000))
        utxos.append(buildUnspent(6000))
        utxos.append(buildUnspent(1000))
        utxos.append(buildUnspent(50_000))
        utxos.append(buildUnspent(120_000))
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 10_000, feePerByte: 1)
        XCTAssertEqual(selected.count, 1)
        XCTAssertEqual(selected.sum(), 50_000)
    }

    func testUtxos3() {
        // Trust/wallet-core: SelectUnpsents3
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(2000))
        utxos.append(buildUnspent(5000))
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 6000, feePerByte: 1)
        XCTAssertEqual(selected.count, 2)
        XCTAssertEqual(selected.sum(), 9000)
    }

    func testUtxos4() {
        // Trust/wallet-core: SelectUnpsents4
        utxos.append(buildUnspent(40_000))
        utxos.append(buildUnspent(30_000))
        utxos.append(buildUnspent(30_000))
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 50_000, feePerByte: 1)
        XCTAssertEqual(selected.count, 2)
        XCTAssertEqual(selected.sum(), 70_000)
    }
    
    func testUtxos5() {
        // Trust/wallet-core: SelectUnpsents5
        utxos.append(buildUnspent(1000))
        utxos.append(buildUnspent(2000))
        utxos.append(buildUnspent(3000))
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(5000))
        utxos.append(buildUnspent(6000))
        utxos.append(buildUnspent(7000))
        utxos.append(buildUnspent(8000))
        utxos.append(buildUnspent(9000))
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 28_000, feePerByte: 1)
        XCTAssertEqual(selected.count, 4)
        XCTAssertEqual(selected.sum(), 30_000)
    }
    
    func testSelectUnpsentsInsufficient()  {
        // Trust/wallet-core: SelectUnpsentsInsufficient
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(4000))
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 15_000, feePerByte: 1)
        XCTAssertEqual(selected.count, 3)
        XCTAssertEqual(selected.sum(), 12_000)
    }

    func testSelectCustom()  {
        // Trust/wallet-core: SelectCustomCase
        utxos.append(buildUnspent(794_121))
        utxos.append(buildUnspent(2_289_357))
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 2_287_189, feePerByte: 61)
        XCTAssertEqual(selected.count, 2)
        XCTAssertEqual(selected.sum(), 3_083_478)

    }

    func testSelectMax()  {
        // Trust/wallet-core: SelectMaxCase
        utxos.append(buildUnspent(10_189_534))
        let selected: [UnspentTransaction] = UnspentTransactionOutputSelector
            .select(utxos: utxos, targetValue: 10_189_534, feePerByte: 1)
        XCTAssertEqual(selected.count, 1)
        XCTAssertEqual(selected.sum(), 10_189_534)
    }
}
