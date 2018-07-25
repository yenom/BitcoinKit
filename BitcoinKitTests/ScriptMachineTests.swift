//
//  ScriptMachineTests.swift
//  BitcoinKitTests
//
//  Created by Akifumi Fujita on 2018/07/19.
//  Copyright © 2018年 BitcoinKit-cash developers. All rights reserved.
//

import XCTest
@testable import BitcoinKit

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
        
        let lockingScript1 = Script.buildPublicKeyHashOut(pubKeyHash: toPubKeyHash)
        let lockingScript2 = Script.buildPublicKeyHashOut(pubKeyHash: fromPubKeyHash)
        
        let sending = TransactionOutput(value: amount, lockingScript: lockingScript1)
        let payback = TransactionOutput(value: balance - amount - fee, lockingScript: lockingScript2)
        let subScript = Data(hex: "76a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac")!
        let inputForSign = TransactionInput(previousOutput: outpoint, signatureScript: subScript, sequence: UInt32.max)
        let _tx = Transaction(version: 1, inputs: [inputForSign], outputs: [sending, payback], lockTime: 0)
        let hashType: SighashType = SighashType.BTC.ALL
        let utxoToSign = TransactionOutput(value: balance, lockingScript: subScript)
        let _txHash = _tx.signatureHash(for: utxoToSign, inputIndex: 0, hashType: hashType)
        guard let signature: Data = try? Crypto.sign(_txHash, privateKey: privateKey) else {
            XCTFail("failed to sign")
            return
        }
        XCTAssertEqual(fromPublicKey.pubkeyHash.hex, "2a539adfd7aefcc02e0196b4ccf76aea88a1f470")
        let signatureWithHashType: Data = signature + UInt8(hashType)
        
        guard let scriptMachine = ScriptMachine(tx: _tx, inputIndex: 0) else {
            XCTFail("failed to sign")
            return
        }
        do {
            try scriptMachine.check(signature: signatureWithHashType, publicKey: fromPublicKey.raw, utxoToSign: utxoToSign)
        } catch (let err) {
            XCTFail("signature is invalid. \(err)")
        }
    }
}
