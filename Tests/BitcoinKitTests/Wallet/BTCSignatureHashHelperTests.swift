//
//  BTCSignatureHashHelperTests.swift
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

class BTCSignatureHashHelperTests: XCTestCase {
    var transaction: Transaction!
    var utxoToSign: TransactionOutput!

    override func setUp() {
        // Transaction in testnet3
        // https://api.blockcypher.com/v1/btc/test3/txs/0189910c263c4d416d5c5c2cf70744f9f6bcd5feaf0b149b02e5d88afbe78992
        let prevTxID = "1524ca4eeb9066b4765effd472bc9e869240c4ecb5c1ee0edb40f8b666088231"
        let hash = Data(Data(hex: prevTxID)!.reversed())
        let index: UInt32 = 1
        let outpoint = TransactionOutPoint(hash: hash, index: index)
        
        let balance: UInt64 = 169012961
        let amount: UInt64  =  50000000
        let fee: UInt64     =  10000000
        
        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")

        let toAddress = try! BitcoinAddress(legacy: "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB")
        
        let lockingScript1 = Script(address: toAddress)!.data
        let lockingScript2 = Script(address: privateKey.publicKey().toBitcoinAddress())!.data
        
        let sending = TransactionOutput(value: amount, lockingScript: lockingScript1)
        let payback = TransactionOutput(value: balance - amount - fee, lockingScript: lockingScript2)
        
        let unsignedInputs: [TransactionInput] = [TransactionInput(previousOutput: outpoint, signatureScript: Data(), sequence: UInt32.max)]
        transaction = Transaction(version: 1,
                                  inputs: unsignedInputs,
                                  outputs: [sending, payback],
                                  lockTime: 0)
        utxoToSign = TransactionOutput(value: 169012961, lockingScript: lockingScript2)
    }

    func testCreateBlankInput() {
        let helper: BTCSignatureHashHelper = BTCSignatureHashHelper(hashType: .ALL)
        let blankInput = helper.createBlankInput(of: transaction.inputs[0])
        XCTAssertEqual(blankInput.serialized().hex,
                       "31820866b6f840db0eeec1b5ecc44092869ebc72d4ff5e76b46690eb4eca24150100000000ffffffff")
    }

    func testCreateSigningInput() {
        let helper: BTCSignatureHashHelper = BTCSignatureHashHelper(hashType: .ALL)
        let signingInput = helper.createSigningInput(of: transaction.inputs[0], from: utxoToSign)
        XCTAssertEqual(signingInput.serialized().hex, "31820866b6f840db0eeec1b5ecc44092869ebc72d4ff5e76b46690eb4eca2415010000001976a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088acffffffff")
    }

    func testCreateInputs() {
        let helper: BTCSignatureHashHelper = BTCSignatureHashHelper(hashType: .ALL)
        let inputs = helper.createInputs(of: transaction, for: utxoToSign, inputIndex: 0)
        XCTAssertEqual(inputs.count, 1)
        XCTAssertEqual(inputs[0].serialized().hex, "31820866b6f840db0eeec1b5ecc44092869ebc72d4ff5e76b46690eb4eca2415010000001976a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088acffffffff")
    }

    func testCreateOutputs() {
        let helper: BTCSignatureHashHelper = BTCSignatureHashHelper(hashType: .ALL)
        let outputs = helper.createOutputs(of: transaction, inputIndex: 0)
        XCTAssertEqual(outputs, transaction.outputs)
    }

    func testSignatureHash() {
        let helper: BTCSignatureHashHelper = BTCSignatureHashHelper(hashType: .ALL)
        let sighash = helper.createSignatureHash(of: transaction, for: utxoToSign, inputIndex: 0)
        XCTAssertEqual(sighash.hex, "fd2f20da1c28b008abcce8a8ac7e1a7687fc944e001a24fc3aacb6a7570a3d0f")
    }
}

extension TransactionOutput: Equatable {
    public static func == (lhs: TransactionOutput, rhs: TransactionOutput) -> Bool {
        return lhs.serialized() == rhs.serialized()
    }
}
