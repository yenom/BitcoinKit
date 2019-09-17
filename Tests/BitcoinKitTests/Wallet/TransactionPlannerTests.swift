//
//  TransactionPlannerTests.swift
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

class TransactionPlannerTests: XCTestCase {
    var planner: TransactionPlanner!
    var utxos: [UnspentTransaction]!
    override func setUp() {
        planner = TransactionPlanner(feePerByte: 1, dustPolicy: .toFee)
        utxos = []
    }
    
    func testEmptyUtxos() {
        // If utxos are empty, returns empty plan
        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 3000)
        XCTAssertTrue(plan.unspentTransactions.isEmpty)
        XCTAssertEqual(plan.amount, 0)
        XCTAssertEqual(plan.fee, 0)
        XCTAssertEqual(plan.change, 0)
    }

    func testTargetValueIsZero() {
        // If targetValue is 0, returns empty plan
        utxos.append(buildUnspent(1000))
        utxos.append(buildUnspent(2000))
        utxos.append(buildUnspent(3000))

        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 0)
        XCTAssertTrue(plan.unspentTransactions.isEmpty)
        XCTAssertEqual(plan.amount, 0)
        XCTAssertEqual(plan.fee, 0)
        XCTAssertEqual(plan.change, 0)
    }
    
    func testTargetValueIsDust() {
        // If targetValue is dust, returns empty plan
        utxos.append(buildUnspent(3000))

        // Dust threshold is 546
        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 545)
        XCTAssertTrue(plan.unspentTransactions.isEmpty)
        XCTAssertEqual(plan.amount, 0)
        XCTAssertEqual(plan.fee, 0)
        XCTAssertEqual(plan.change, 0)
    }

    func testTargetValueIsNotDust() {
        // If targetValue is not dust, returns valid plan
        utxos.append(buildUnspent(3000))
        
        // Dust threshold is 546
        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 546)
        XCTAssertEqual(plan.unspentTransactions.count, 1)
        XCTAssertEqual(plan.unspentTransactions.sum(), 3000)
        XCTAssertEqual(plan.amount, 546)
        XCTAssertEqual(plan.fee, 226)
        XCTAssertEqual(plan.change, 2228)
    }
    
    func testSmallUtxos() {
        // Fee for single input is 148, so these are usable
        for _ in 0...20 {
            utxos.append(buildUnspent(200))
        }
        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 600)
        
        XCTAssertEqual(plan.unspentTransactions.count, 13)
        XCTAssertEqual(plan.unspentTransactions.sum(), 2600)
        XCTAssertEqual(plan.amount, 600)
        XCTAssertEqual(plan.fee, 2000)
        XCTAssertEqual(plan.change, 0)
    }

    func testChangeIsNotDust() {
        // If change is not dust, returns plan with change
        utxos.append(buildUnspent(10_772))

        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 10_000)
        XCTAssertEqual(plan.unspentTransactions.count, 1)
        XCTAssertEqual(plan.unspentTransactions.sum(), 10_772)
        XCTAssertEqual(plan.amount, 10_000)
        XCTAssertEqual(plan.fee, 226)
        XCTAssertEqual(plan.change, 546)
    }

    func testChangeIsDustAndPolicyIsToReceiver() {
        // If change is dust and politcy is to receiver, returns plan of amount with dust
        utxos.append(buildUnspent(10_771))

        planner.dustPolicy = .toReceiver

        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 10_000)
        XCTAssertEqual(plan.unspentTransactions.count, 1)
        XCTAssertEqual(plan.unspentTransactions.sum(), 10_771)
        XCTAssertEqual(plan.amount, 10_579)
        XCTAssertEqual(plan.fee, 192)
        XCTAssertEqual(plan.change, 0)
    }

    func testChangeIsDustAndPolicyIsToFee() {
        // If change is dust and politcy is to fee, returns plan of fee with dust
        utxos.append(buildUnspent(10_771))

        planner.dustPolicy = .toFee

        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 10_000)
        XCTAssertEqual(plan.unspentTransactions.count, 1)
        XCTAssertEqual(plan.unspentTransactions.sum(), 10_771)
        XCTAssertEqual(plan.amount, 10_000)
        XCTAssertEqual(plan.fee, 771)
        XCTAssertEqual(plan.change, 0)
    }

    func testAvailableAmountIsDust() {
        // If available amount is dust, returns empty plan
        utxos.append(buildUnspent(737))

        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 546)
        XCTAssertTrue(plan.unspentTransactions.isEmpty)
        XCTAssertEqual(plan.amount, 0)
        XCTAssertEqual(plan.fee, 0)
        XCTAssertEqual(plan.change, 0)
    }

    func testAvailableAmountIsNotDust() {
        // If available amount is not dust, returns valid plan
        utxos.append(buildUnspent(738))

        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 546)
        XCTAssertEqual(plan.unspentTransactions.count, 1)
        XCTAssertEqual(plan.unspentTransactions.sum(), 738)
        XCTAssertEqual(plan.amount, 546)
        XCTAssertEqual(plan.fee, 192)
        XCTAssertEqual(plan.change, 0)
    }

    func testUtxos1() {
        // Trust/wallet-core: SelectUnpsents1
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(2000))
        utxos.append(buildUnspent(6000))
        utxos.append(buildUnspent(1000))
        utxos.append(buildUnspent(11_000))
        utxos.append(buildUnspent(12_000))
        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 5000)
        XCTAssertEqual(plan.unspentTransactions.count, 1)
        XCTAssertEqual(plan.unspentTransactions.sum(), 11_000)
        XCTAssertEqual(plan.amount, 5000)
        XCTAssertEqual(plan.fee, 226)
        XCTAssertEqual(plan.change, 5774)
    }
    
    func testUtxos2() {
        // Trust/wallet-core: SelectUnpsents2
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(2000))
        utxos.append(buildUnspent(6000))
        utxos.append(buildUnspent(1000))
        utxos.append(buildUnspent(50_000))
        utxos.append(buildUnspent(120_000))
        
        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 10_000)
        XCTAssertEqual(plan.unspentTransactions.count, 1)
        XCTAssertEqual(plan.unspentTransactions.sum(), 50_000)
        XCTAssertEqual(plan.amount, 10_000)
        XCTAssertEqual(plan.fee, 226)
        XCTAssertEqual(plan.change, 39_774)
    }
    
    func testUtxos3() {
        // Trust/wallet-core: SelectUnpsents3
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(2000))
        utxos.append(buildUnspent(5000))

        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 6000)
        XCTAssertEqual(plan.unspentTransactions.count, 2)
        XCTAssertEqual(plan.unspentTransactions.sum(), 9000)
        XCTAssertEqual(plan.amount, 6000)
        XCTAssertEqual(plan.fee, 374)
        XCTAssertEqual(plan.change, 2626)
    }
    
    func testUtxos4() {
        // Trust/wallet-core: SelectUnpsents4
        utxos.append(buildUnspent(40_000))
        utxos.append(buildUnspent(30_000))
        utxos.append(buildUnspent(30_000))

        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 50_000)
        XCTAssertEqual(plan.unspentTransactions.count, 2)
        XCTAssertEqual(plan.unspentTransactions.sum(), 70_000)
        XCTAssertEqual(plan.amount, 50_000)
        XCTAssertEqual(plan.fee, 374)
        XCTAssertEqual(plan.change, 19_626)
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

        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 28_000)
        XCTAssertEqual(plan.unspentTransactions.count, 4)
        XCTAssertEqual(plan.unspentTransactions.sum(), 30_000)
        XCTAssertEqual(plan.amount, 28_000)
        XCTAssertEqual(plan.fee, 670)
        XCTAssertEqual(plan.change, 1330)
    }
    
    func testSelectUnpsentsInsufficient()  {
        // Trust/wallet-core: SelectUnpsentsInsufficient
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(4000))
        utxos.append(buildUnspent(4000))
        
        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 15_000)
        XCTAssertEqual(plan.unspentTransactions.count, 3)
        XCTAssertEqual(plan.unspentTransactions.sum(), 12_000)
        XCTAssertEqual(plan.amount, 11_512)
        XCTAssertEqual(plan.fee, 488)
        XCTAssertEqual(plan.change, 0)
    }
    
    func testSelectCustom()  {
        // Trust/wallet-core: SelectCustomCase
        utxos.append(buildUnspent(794_121))
        utxos.append(buildUnspent(2_289_357))

        planner.feePerByte = 61
        
        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 2_287_189)
        XCTAssertEqual(plan.unspentTransactions.count, 2)
        XCTAssertEqual(plan.unspentTransactions.sum(), 3_083_478)
        XCTAssertEqual(plan.amount, 2_287_189)
        XCTAssertEqual(plan.fee, 22_814)
        XCTAssertEqual(plan.change, 773_475)
    }
    
    func testSelectMax()  {
        // Trust/wallet-core: SelectMaxCase
        utxos.append(buildUnspent(10_189_534))
        
        let plan: TransactionPlan = planner.plan(unspentTransactions: utxos, target: 10_189_534)
        XCTAssertEqual(plan.unspentTransactions.count, 1)
        XCTAssertEqual(plan.unspentTransactions.sum(), 10_189_534)
        XCTAssertEqual(plan.amount, 10_189_342)
        XCTAssertEqual(plan.fee, 192)
        XCTAssertEqual(plan.change, 0)
    }
}
