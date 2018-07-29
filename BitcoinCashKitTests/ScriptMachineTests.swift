//
//  ScriptMachineTests.swift
//
//  Copyright © 2018 BitcoinCashKit developers
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
@testable import BitcoinCashKit

class ScriptMachineTests: XCTestCase {
    
    func testCheck() {
        // Transaction in testnet3
        // https://api.blockcypher.com/v1/btc/test3/txs/0189910c263c4d416d5c5c2cf70744f9f6bcd5feaf0b149b02e5d88afbe78992
        let prevTxID = "1524ca4eeb9066b4765effd472bc9e869240c4ecb5c1ee0edb40f8b666088231"
        // hash.reversed = txid
        let hash = Data(Data(hex: prevTxID)!.reversed())
        let index: UInt32 = 1
        let outpoint = TransactionOutPoint(hash: hash, index: index)
        
        let balance: Int64 = 169012961
        let amount: Int64  =  50000000
        let fee: Int64     =  10000000
        let toAddress = "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB" // https://testnet.coinfaucet.eu/en/
        
        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
        
        let fromPublicKey = privateKey.publicKey()
        let fromPubKeyHash = Crypto.sha256ripemd160(fromPublicKey.raw)
        let toPubKeyHash = Base58.decode(toAddress)!.dropFirst().dropLast(4)
        
        // unsigned tx
        let lockingScript1 = Script.buildPublicKeyHashOut(pubKeyHash: toPubKeyHash)
        let lockingScript2 = Script.buildPublicKeyHashOut(pubKeyHash: fromPubKeyHash)
        
        let sending = TransactionOutput(value: amount, lockingScript: lockingScript1)
        let payback = TransactionOutput(value: balance - amount - fee, lockingScript: lockingScript2)
        let subScript = Data(hex: "76a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac")!
        let inputForSign = TransactionInput(previousOutput: outpoint, signatureScript: subScript, sequence: UInt32.max)
        let unsignedTx = Transaction(version: 1, inputs: [inputForSign], outputs: [sending, payback], lockTime: 0)
        
        // sign
        let hashType: SighashType = SighashType.BTC.ALL
        let utxoToSign = TransactionOutput(value: balance, lockingScript: subScript)
        let _txHash = unsignedTx.signatureHash(for: utxoToSign, inputIndex: 0, hashType: hashType)
        guard let signature: Data = try? Crypto.sign(_txHash, privateKey: privateKey) else {
            XCTFail("Failed to sign tx.")
            return
        }
        
        // unlock script
        XCTAssertEqual(fromPublicKey.pubkeyHash.hex, "2a539adfd7aefcc02e0196b4ccf76aea88a1f470")
        let unlockScript: Script = Script()
        try! unlockScript.append(signature + UInt8(hashType))
        try! unlockScript.append(fromPublicKey.raw)
        
        // signed tx
        let txin = TransactionInput(previousOutput: outpoint, signatureScript: unlockScript.data, sequence: UInt32.max)
        let signedTx = Transaction(version: 1, inputs: [txin], outputs: [sending, payback], lockTime: 0)
        
        // crypto verify
        do {
            let sigData: Data = signature + UInt8(hashType)
            let pubkeyData: Data = fromPublicKey.raw
            let result = try Crypto.verifySigData(for: signedTx, inputIndex: 0, utxo: utxoToSign, sigData: sigData, pubKeyData: pubkeyData)
            XCTAssertTrue(result)
        } catch (let err) {
            XCTFail("Crypto verifySigData failed. \(err)")
        }
        
        // script machine verify
        do {
            let result = try ScriptMachine.verifyTransaction(signedTx: signedTx, inputIndex: 0, utxo: utxoToSign)
            XCTAssertTrue(result)
        } catch (let err) {
            XCTFail("Script machine verify failed. \(err)")
        }
    }
}
