//
//  SendViewController.swift
//
//  Copyright © 2018 Kishikawa Katsumi
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

import UIKit
import BitcoinKit

class SendViewController: UIViewController, PeerGroupDelegate {
    var peerGroup: PeerGroup?
    var payments = [Payment]() 

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startSync()
        getUnspentTransactions()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopSync()
    }
    
    func startSync() {
        print("start sync")
        let blockStore = try! SQLiteBlockStore.default()
        let blockChain = BlockChain(network: AppController.shared.network, blockStore: blockStore)
        
        peerGroup = PeerGroup(blockChain: blockChain)
        peerGroup?.delegate = self
        
        for address in usedAddresses() {
            if let publicKey = address.publicKey {
                peerGroup?.addFilter(publicKey)
            }
            peerGroup?.addFilter(address.data)
        }
        
        peerGroup?.start()
    }
    
    func stopSync() {
        print("stop sync")
        peerGroup?.stop()
    }
    
    private func usedAddresses() -> [Address] {
        var addresses = [Address]()
        guard let wallet = AppController.shared.wallet else {
            return []
        }
        for index in 0..<(AppController.shared.externalIndex + 20) {
            if let address = try? wallet.receiveAddress(index: index) {
                addresses.append(address)
            }
        }
        for index in 0..<(AppController.shared.internalIndex + 20) {
            if let address = try? wallet.changeAddress(index: index) {
                addresses.append(address)
            }
        }
        return addresses
    }
    
    private func usedKeys() -> [PrivateKey] {
        var keys = [PrivateKey]()
        guard let wallet = AppController.shared.wallet else {
            return []
        }
        // Receive key
        for index in 0..<(AppController.shared.externalIndex + 20) {
            if let key = try? wallet.privateKey(index: index) {
                keys.append(key)
            }
        }
        // Change key
        for index in 0..<(AppController.shared.internalIndex + 20) {
            if let key = try? wallet.changePrivateKey(index: index) {
                keys.append(key)
            }
        }

        return keys
    }
    
    @IBAction func send0_1(_ sender: UIButton) {
        sendToSomeAddress(10000000)
    }
    
    @IBAction func send0_5(_ sender: UIButton) {
        sendToSomeAddress(50000000)
    }

    @IBAction func send1_0(_ sender: UIButton) {
        sendToSomeAddress(100000000)
    }

    
    private func sendToSomeAddress(_ amount: Int64) {
        let toAddress: Address = try! AddressFactory.create("bchtest:qpytf7xczxf2mxa3gd6s30rthpts0tmtgyw8ud2sy3")
        let changeAddress: Address = try! AppController.shared.wallet!.changeAddress()
        
        var utxos: [UnspentTransaction] = []
        for p in payments {
            let value = p.amount
            let lockScript = Script.buildPublicKeyHashOut(pubKeyHash: p.to.data)
            let txHash = Data(p.txid.reversed())
            let txIndex = UInt32(p.index)
            print(p.txid.hex, txIndex, lockScript.hex, value)
            
            let unspentOutput = TransactionOutput(value: value, lockingScript: lockScript)
            let unspentOutpoint = TransactionOutPoint(hash: txHash, index: txIndex)
            let utxo = UnspentTransaction(output: unspentOutput, outpoint: unspentOutpoint)
            utxos.append(utxo)
        }
        
        let unsignedTx = createUnsignedTx(toAddress: toAddress, amount: amount, changeAddress: changeAddress, utxos: utxos)
        let signedTx = signTx(unsignedTx: unsignedTx, keys: usedKeys())
        
        peerGroup?.sendTransaction(transaction: signedTx)
    }
    
    func peerGroupDidStop(_ peerGroup: PeerGroup) {
        peerGroup.delegate = nil
        self.peerGroup = nil
    }
    
    func getUnspentTransactions() {
        let blockStore = try! SQLiteBlockStore.default()
        
        payments = []
        for address in usedAddresses() {
            payments.append(contentsOf: try! blockStore.unspentTransactions(address: address))
        }
    }

}


// TODO: select utxos and decide fee
public func selectTx(from utxos: [UnspentTransaction], amount: Int64) -> (utxos: [UnspentTransaction], fee: Int64) {
    return (utxos, 500)
}

public func createUnsignedTx(toAddress: Address, amount: Int64, changeAddress: Address, utxos: [UnspentTransaction]) -> UnsignedTransaction {
    let (utxos, fee) = selectTx(from: utxos, amount: amount)
    let totalAmount: Int64 = utxos.reduce(0) { $0 + $1.output.value }
    let change: Int64 = totalAmount - amount - fee
    
    let toPubKeyHash: Data = toAddress.data
    let changePubkeyHash: Data = changeAddress.data
    
    let lockingScriptTo = Script.buildPublicKeyHashOut(pubKeyHash: toPubKeyHash)
    let lockingScriptChange = Script.buildPublicKeyHashOut(pubKeyHash: changePubkeyHash)
    
    let toOutput = TransactionOutput(value: amount, lockingScript: lockingScriptTo)
    let changeOutput = TransactionOutput(value: change, lockingScript: lockingScriptChange)
    
    // この後、signatureScriptやsequenceは更新される
    let unsignedInputs = utxos.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: Data(), sequence: UInt32.max) }
    let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: [toOutput, changeOutput], lockTime: 0)
    return UnsignedTransaction(tx: tx, utxos: utxos)
}

public func signTx(unsignedTx: UnsignedTransaction, keys: [PrivateKey]) -> Transaction {
    var inputsToSign = unsignedTx.tx.inputs
    var transactionToSign: Transaction {
        return Transaction(version: unsignedTx.tx.version, inputs: inputsToSign, outputs: unsignedTx.tx.outputs, lockTime: unsignedTx.tx.lockTime)
    }
    
    // Signing
    let hashType = SighashType.BCH.ALL
    for (i, utxo) in unsignedTx.utxos.enumerated() {
        let pubkeyHash: Data = Script.getPublicKeyHash(from: utxo.output.lockingScript)
        
        let keysOfUtxo: [PrivateKey] = keys.filter { $0.publicKey().pubkeyHash == pubkeyHash }
        guard let key = keysOfUtxo.first else {
            print("No keys to this txout : \(utxo.output.value)")
            continue
        }
        print("Value of signing txout : \(utxo.output.value)")
        
        let sighash: Data = transactionToSign.signatureHash(for: utxo.output, inputIndex: i, hashType: SighashType.BCH.ALL)
        let signature: Data = try! Crypto.sign(sighash, privateKey: key)
        let txin = inputsToSign[i]
        let pubkey = key.publicKey()
        
        let unlockingScript = Script.buildPublicKeyUnlockingScript(signature: signature, pubkey: pubkey, hashType: hashType)
        
        // TODO: sequenceの更新
        inputsToSign[i] = TransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript, sequence: txin.sequence)
    }
    return transactionToSign
}
