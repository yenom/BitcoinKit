//
//  TestHelpersTests.swift
//  BitcoinKitTests
//
//  Created by Akifumi Fujita on 2018/07/08.
//  Copyright © 2018年 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import BitcoinKit

class TestHelpersTests: XCTestCase {
    
    func testSelectTx() {
        let privateKey = try! PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
        let pubKeyHash = privateKey.publicKey().pubkeyHash
        let p2pkh = Script.buildPublicKeyHashOut(pubKeyHash: pubKeyHash)
        let transactionOutPoint = TransactionOutPoint(hash: Data(), index: 0)
        
        do {
            var utxos = [UnspentTransaction]()
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 4000, lockingScript: p2pkh), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 2000, lockingScript: p2pkh), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 6000, lockingScript: p2pkh), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 1000, lockingScript: p2pkh), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 11000, lockingScript: p2pkh), outpoint: transactionOutPoint))
            utxos.append(UnspentTransaction(output: TransactionOutput(value: 12000, lockingScript: p2pkh), outpoint: transactionOutPoint))
            let (selectedOutputs, _) = selectTx(from: utxos, targetValue: 5000)
            XCTAssertEqual(selectedOutputs.count, 1)
            XCTAssertEqual(selectedOutputs[0].output.value, 11000)
        } catch {
            XCTFail("Some Error: \(error)")
        }
    }
    
    func testCalculateFee() {
        // 1. default nOut and feePerByte
        XCTAssertEqual(calculateFee(nIn: 1), 226)
        XCTAssertEqual(calculateFee(nIn: 2), 374)
        XCTAssertEqual(calculateFee(nIn: 3), 522)
        
        // 2. default feePerByte
        XCTAssertEqual(calculateFee(nIn: 1, nOut: 1, feePerByte: 1), 192)
        XCTAssertEqual(calculateFee(nIn: 1, nOut: 2, feePerByte: 1), 226)
        XCTAssertEqual(calculateFee(nIn: 2, nOut: 1, feePerByte: 1), 340)
        XCTAssertEqual(calculateFee(nIn: 2, nOut: 2, feePerByte: 1), 374)
        XCTAssertEqual(calculateFee(nIn: 3, nOut: 1, feePerByte: 1), 488)
        XCTAssertEqual(calculateFee(nIn: 3, nOut: 2, feePerByte: 1), 522)
        
        // 3. custom feePerByte
        XCTAssertEqual(calculateFee(nIn: 1, nOut: 1, feePerByte: 2), 192*2)
        XCTAssertEqual(calculateFee(nIn: 1, nOut: 2, feePerByte: 2), 226*2)
        XCTAssertEqual(calculateFee(nIn: 2, nOut: 1, feePerByte: 3), 340*3)
        XCTAssertEqual(calculateFee(nIn: 2, nOut: 2, feePerByte: 3), 374*3)
        XCTAssertEqual(calculateFee(nIn: 3, nOut: 1, feePerByte: 4), 488*4)
        XCTAssertEqual(calculateFee(nIn: 3, nOut: 2, feePerByte: 4), 522*4)
    }
}
