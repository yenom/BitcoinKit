//
//  BCHSignatureHashHelperTests.swift
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

class BCHSignatureHashHelperTests: XCTestCase {
    // Transaction on Bitcoin Cash Mainnet
    // TxID : 96ee20002b34e468f9d3c5ee54f6a8ddaa61c118889c4f35395c2cd93ba5bbb4
    // https://explorer.bitcoin.com/bch/tx/96ee20002b34e468f9d3c5ee54f6a8ddaa61c118889c4f35395c2cd93ba5bbb4
    
    // TransactionOutput
    var prevTxLockScript: Data!// = Data(hex: "76a914aff1e0789e5fe316b729577665aa0a04d5b0f8c788ac")
    var prevTxOutput: TransactionOutput!// = TransactionOutput(value: 5151, lockingScript: prevTxLockScript!)
    
    // TransactionOutpoint
    var prevTxID: String!// = "050d00e2e18ef13969606f1ceee290d3f49bd940684ce39898159352952b8ce2"
    var prevTxHash: Data!// = Data(Data(hex: prevTxID)!.reversed())
    var prevTxOutPoint: TransactionOutPoint!// = TransactionOutPoint(hash: prevTxHash, index: 2)
    
    // UnspentTransaction
    var utxo: UnspentTransaction!// = UnspentTransaction(output: prevTxOutput,
                                  //outpoint: prevTxOutPoint)
    var plan: TransactionPlan!// = TransactionPlan(utxos: [utxo], amount: 600, fee: 226, change: 4325)
    var toAddress: Address!// = try! AddressFactory.create("bitcoincash:qpmfhhledgp0jy66r5vmwjwmdfu0up7ujqcp07ha9v")
    var changeAddress: Address!// = try! AddressFactory.create("bitcoincash:qz0q3xmg38sr94rw8wg45vujah7kzma3cskxymnw06")
    var tx: Transaction!// = TransactionBuilder.build(from: plan, toAddress: toAddress, changeAddress: changeAddress)

    override func setUp() {
        // Transaction on Bitcoin Cash Mainnet
        // TxID : 96ee20002b34e468f9d3c5ee54f6a8ddaa61c118889c4f35395c2cd93ba5bbb4
        // https://explorer.bitcoin.com/bch/tx/96ee20002b34e468f9d3c5ee54f6a8ddaa61c118889c4f35395c2cd93ba5bbb4
        
        // TransactionOutput
        prevTxLockScript = Data(hex: "76a914aff1e0789e5fe316b729577665aa0a04d5b0f8c788ac")!
        prevTxOutput = TransactionOutput(value: 5151, lockingScript: prevTxLockScript!)
        
        // TransactionOutpoint
        prevTxID = "050d00e2e18ef13969606f1ceee290d3f49bd940684ce39898159352952b8ce2"
        prevTxHash = Data(Data(hex: prevTxID)!.reversed())
        prevTxOutPoint = TransactionOutPoint(hash: prevTxHash, index: 2)
        
        // UnspentTransaction
        utxo = UnspentTransaction(output: prevTxOutput,
                                      outpoint: prevTxOutPoint)
        plan = TransactionPlan(utxos: [utxo], amount: 600, fee: 226, change: 4325)
        toAddress = try! AddressFactory.create("bitcoincash:qpmfhhledgp0jy66r5vmwjwmdfu0up7ujqcp07ha9v")
        changeAddress = try! AddressFactory.create("bitcoincash:qz0q3xmg38sr94rw8wg45vujah7kzma3cskxymnw06")
        tx = TransactionBuilder.build(from: plan, toAddress: toAddress, changeAddress: changeAddress)
    }

    func testPrevoutHash() {
        let helper = BCHSignatureHashHelper(hashType: .ALL)
        let expected = "92fd2522986c2c335fef0e3fd8a70f838da0402834f6444d0ae5a369278d4d26"
        XCTAssertEqual(helper.createPrevoutHash(of: tx).hex, expected)
    }
    
    func testSequenceHash() {
        let helper = BCHSignatureHashHelper(hashType: .ALL)
        let expected = "3bb13029ce7b1f559ef5e747fcac439f1455a2ec7c5f09b72290795e70665044"
        XCTAssertEqual(helper.createSequenceHash(of: tx).hex, expected)
    }
    
    func testOutputsHash() {
        let helper = BCHSignatureHashHelper(hashType: .ALL)
        let expected = "729d6e07e0048f5503a394692163c44a5dac384b3e0dbab7a0d3b63dd6103965"
        XCTAssertEqual(helper.createOutputsHash(of: tx, index: 0).hex, expected)
    }

    func testSignatureHash() {
        let helper = BCHSignatureHashHelper(hashType: .ALL)
        let expected = "1136d4975aee4ff6ccf0b8a9c640532f563b48d9856fdc9682c37a071702937c"
        XCTAssertEqual(helper.createSignatureHash(of: tx, for: utxo.output, inputIndex: 0).hex, expected)
    }
}
