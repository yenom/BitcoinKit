//
//  TransactionBuilderTests.swift
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

class TransactionBuilderTests: XCTestCase {
    func testBTCTransaction() {
        // Transaction in testnet3
        // https://api.blockcypher.com/v1/btc/test3/txs/0189910c263c4d416d5c5c2cf70744f9f6bcd5feaf0b149b02e5d88afbe78992
        
        // TransactionOutput
        let prevTxLockScript = Data(hex: "76a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac")
        let prevTxOutput = TransactionOutput(value: 169_012_961, lockingScript: prevTxLockScript!)
        
        // TransactionOutpoint
        let prevTxID = "1524ca4eeb9066b4765effd472bc9e869240c4ecb5c1ee0edb40f8b666088231"
        let prevTxHash = Data(Data(hex: prevTxID)!.reversed())
        let prevTxOutPoint = TransactionOutPoint(hash: prevTxHash, index: 1)
        
        // UnspentTransaction
        let unspentTransaction = UnspentTransaction(output: prevTxOutput,
                                      outpoint: prevTxOutPoint)
        let plan = TransactionPlan(unspentTransactions: [unspentTransaction], amount: 50_000_000, fee: 10_000_000, change: 109_012_961)
        let toAddress = try! BitcoinAddress(legacy: "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB")
        let privKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
        let changeAddress = privKey.publicKey().toBitcoinAddress()
        let tx: Transaction = TransactionBuilder.build(from: plan, toAddress: toAddress, changeAddress: changeAddress)
        
        let expectedSerializedTx: Data = Data(hex: "010000000131820866b6f840db0eeec1b5ecc44092869ebc72d4ff5e76b46690eb4eca24150100000000ffffffff0280f0fa02000000001976a9149f9a7abd600c0caa03983a77c8c3df8e062cb2fa88ace1677f06000000001976a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac00000000")!
        XCTAssertEqual(tx.serialized().hex, expectedSerializedTx.hex)
        // TODO: signature hash test
//        let expectedSignatureHash: Data = Data(hex: "fd2f20da1c28b008abcce8a8ac7e1a7687fc944e001a24fc3aacb6a7570a3d0f")!
//        XCTAssertEqual(tx.signatureHash(for: prevTxOutput, inputIndex: 0, hashType: SighashType.BTC.ALL), expectedSignatureHash)
    }

    func testBCHTransaction() {
        // Transaction on Bitcoin Cash Mainnet
        // TxID : 96ee20002b34e468f9d3c5ee54f6a8ddaa61c118889c4f35395c2cd93ba5bbb4
        // https://explorer.bitcoin.com/bch/tx/96ee20002b34e468f9d3c5ee54f6a8ddaa61c118889c4f35395c2cd93ba5bbb4
        
        // TransactionOutput
        let prevTxLockScript = Data(hex: "76a914aff1e0789e5fe316b729577665aa0a04d5b0f8c788ac")
        let prevTxOutput = TransactionOutput(value: 5151, lockingScript: prevTxLockScript!)
        
        // TransactionOutpoint
        let prevTxID = "050d00e2e18ef13969606f1ceee290d3f49bd940684ce39898159352952b8ce2"
        let prevTxHash = Data(Data(hex: prevTxID)!.reversed())
        let prevTxOutPoint = TransactionOutPoint(hash: prevTxHash, index: 2)
        
        // UnspentTransaction
        let unspentTransaction = UnspentTransaction(output: prevTxOutput,
                                      outpoint: prevTxOutPoint)
        let plan = TransactionPlan(unspentTransactions: [unspentTransaction], amount: 600, fee: 226, change: 4325)
        let toAddress = try! BitcoinAddress(cashaddr: "bitcoincash:qpmfhhledgp0jy66r5vmwjwmdfu0up7ujqcp07ha9v")
        let changeAddress = try! BitcoinAddress(cashaddr: "bitcoincash:qz0q3xmg38sr94rw8wg45vujah7kzma3cskxymnw06")
        let tx = TransactionBuilder.build(from: plan, toAddress: toAddress, changeAddress: changeAddress)
        let expectedSerializedTx: Data = Data(hex: "0100000001e28c2b955293159898e34c6840d99bf4d390e2ee1c6f606939f18ee1e2000d050200000000ffffffff0258020000000000001976a914769bdff96a02f9135a1d19b749db6a78fe07dc9088ace5100000000000001976a9149e089b6889e032d46e3b915a3392edfd616fb1c488ac00000000")!
        XCTAssertEqual(tx.serialized().hex, expectedSerializedTx.hex)
        // TODO: SignatureHash test
//        let expectedSignatureHash: Data = Data(hex: "1136d4975aee4ff6ccf0b8a9c640532f563b48d9856fdc9682c37a071702937c")!
//        XCTAssertEqual(tx.signatureHash(for: prevTxOutput, inputIndex: 0, hashType: SighashType.BCH.ALL), expectedSignatureHash)
    }
}
