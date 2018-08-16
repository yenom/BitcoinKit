//
//  TestHelpersTests.swift
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

class TestHelpersTests: XCTestCase {
    
    func testSelectTx() {
        let transactionOutPoint = TransactionOutPoint(hash: Data(), index: 0)
        
        // 1. Single Tx about 2x
        do {
            var utxos = [UnspentTransaction]()
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 2000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 6000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 1000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 11000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 12000, lockingScript: Data()), outpoint: transactionOutPoint))
            let (selectedOutputs, _) = try selectTx(from: utxos, targetValue: 5000)
            XCTAssertEqual(selectedOutputs.count, 1)
            XCTAssertEqual(selectedOutputs[0].output.value, 11000)
        } catch {
            XCTFail("Some Error: \(error)")
        }
        
        // 2. Single smallest Tx greater than 1x
        do {
            var utxos = [UnspentTransaction]()
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 2000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 6000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 1000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 50000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 120000, lockingScript: Data()), outpoint: transactionOutPoint))
            
            let (selectedOutputs, _) = try selectTx(from: utxos, targetValue: 10000)
            XCTAssertEqual(selectedOutputs.count, 1)
            XCTAssertEqual(selectedOutputs[0].output.value, 50000)
        } catch {
            XCTFail("Some Error: \(error)")
        }
        
        // 3. Two Txs about 2x value of target
        do {
            var utxos = [UnspentTransaction]()
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 2000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 5000, lockingScript: Data()), outpoint: transactionOutPoint))
            
            let (selectedOutputs, _) = try selectTx(from: utxos, targetValue: 6000)
            XCTAssertEqual(selectedOutputs.count, 2)
            XCTAssertEqual(selectedOutputs[0].output.value, 4000)
            XCTAssertEqual(selectedOutputs[1].output.value, 5000)
        } catch {
            XCTFail("Some Error: \(error)")
        }
        
        // 4. Two smallest Txs greater than 1x
        do {
            var utxos = [UnspentTransaction]()
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 40000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 30000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 30000, lockingScript: Data()), outpoint: transactionOutPoint))
            
            let (selectedOutputs, _) = try selectTx(from: utxos, targetValue: 50000)
            XCTAssertEqual(selectedOutputs.count, 2)
            XCTAssertEqual(selectedOutputs[0].output.value, 30000)
            XCTAssertEqual(selectedOutputs[1].output.value, 40000)
        } catch {
            XCTFail("Some Error: \(error)")
        }
        
        // 5. Multiple smallest txs greater than 1x
        do {
            var utxos = [UnspentTransaction]()
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 1000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 2000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 3000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 5000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 6000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 7000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 8000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 9000, lockingScript: Data()), outpoint: transactionOutPoint))
            
            let (selectedOutputs, _) = try selectTx(from: utxos, targetValue: 28000)
            XCTAssertEqual(selectedOutputs.count, 4)
            XCTAssertEqual(selectedOutputs[0].output.value, 6000)
            XCTAssertEqual(selectedOutputs[1].output.value, 7000)
            XCTAssertEqual(selectedOutputs[2].output.value, 8000)
            XCTAssertEqual(selectedOutputs[3].output.value, 9000)
        } catch {
            XCTFail("Some Error: \(error)")
        }
        
        // 6. Insufficient Fund
        do {
            var utxos = [UnspentTransaction]()
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: Data()), outpoint: transactionOutPoint))
            
            do {
                _ = try selectTx(from: utxos, targetValue: 15000)
                XCTFail("Should throw 'insufficientUtxos'")
            } catch UtxoSelectError.insufficient {
                // Success
            } catch {
                XCTFail("Unknown error occurred")
            }
        }
        
        // 7. Insufficient funds because of fee
        do {
            var utxos = [UnspentTransaction]()
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: Data()), outpoint: transactionOutPoint))
            
            do {
                _ = try selectTx(from: utxos, targetValue: 12000)
                XCTFail("Should throw 'insufficientUtxos'")
            } catch UtxoSelectError.insufficient {
                // Success
            } catch {
                XCTFail("Unknown error occurred")
            }
        }
        
        // 8. Use all txs with discarding dust change
        do {
            var utxos = [UnspentTransaction]()
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: Data()), outpoint: transactionOutPoint))
            
            let (selectedOutputs, fee) = try selectTx(from: utxos, targetValue: 11000, dustThreshhold: 1000)
            print("fee = ", fee)
            XCTAssertEqual(selectedOutputs.count, 3)
            XCTAssertEqual(selectedOutputs[0].output.value, 4000)
            XCTAssertEqual(selectedOutputs[1].output.value, 4000)
            XCTAssertEqual(selectedOutputs[2].output.value, 4000)
        } catch {
            XCTFail("Some Error: \(error)")
        }
        
        // 9. not select dust change
        do {
            var utxos = [UnspentTransaction]()
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 2000, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 5100, lockingScript: Data()), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 10000, lockingScript: Data()), outpoint: transactionOutPoint))
            
            let (selectedOutputs, _) = try selectTx(from: utxos, targetValue: 15000, dustThreshhold: 1000)
            XCTAssertEqual(selectedOutputs.count, 3)
            XCTAssertEqual(selectedOutputs[0].output.value, 2000)
            XCTAssertEqual(selectedOutputs[1].output.value, 5100)
            XCTAssertEqual(selectedOutputs[2].output.value, 10000)
        } catch {
            XCTFail("Some Error: \(error)")
        }
        
        // 10. Discard dust tx with Single utxo
        do {
            var utxos = [UnspentTransaction]()
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 79618, lockingScript: Data()), outpoint: transactionOutPoint))
            
            let (selectedOutputs, _) = try selectTx(from: utxos, targetValue: 70838, dustThreshhold: 10000)
            XCTAssertEqual(selectedOutputs.count, 1)
            XCTAssertEqual(selectedOutputs[0].output.value, 79618)
            
        } catch {
            XCTFail("Unknown error occurred")
        }
        
        // 11. Target is zero and no utxo
        do {
            let (selectedOutputs, _) = try selectTx(from: [], targetValue: 0, dustThreshhold: 10000)
            XCTAssertEqual(selectedOutputs.count, 0)
        } catch {
            XCTFail("Unknown error occurred")
        }
    }
    
    func testFeeCalculate() {
        // 1. default nOut and feePerByte
        XCTAssertEqual(Fee.calculate(nIn: 1), 226)
        XCTAssertEqual(Fee.calculate(nIn: 2), 374)
        XCTAssertEqual(Fee.calculate(nIn: 3), 522)
        
        // 2. default feePerByte
        XCTAssertEqual(Fee.calculate(nIn: 1, nOut: 1), 192)
        XCTAssertEqual(Fee.calculate(nIn: 1, nOut: 2), 226)
        XCTAssertEqual(Fee.calculate(nIn: 2, nOut: 1), 340)
        XCTAssertEqual(Fee.calculate(nIn: 2, nOut: 2), 374)
        XCTAssertEqual(Fee.calculate(nIn: 3, nOut: 1), 488)
        XCTAssertEqual(Fee.calculate(nIn: 3, nOut: 2), 522)
    }
}
