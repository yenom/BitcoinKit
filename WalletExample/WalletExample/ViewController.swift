//
//  ViewController.swift
//  WalletExample
//
//  Created by Shun Usami on 2018/09/18.
//  Copyright © 2018 Yenom Inc. All rights reserved.
//

import UIKit
import BitcoinKit

class ViewController: UIViewController {
    @IBOutlet private weak var qrCodeImageView: UIImageView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var destinationAddressTextField: UITextField!
    
    private var wallet: Wallet?  = Wallet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createWalletIfNeeded()
        self.updateLabels()
    }
    
    func createWalletIfNeeded() {
        if wallet == nil {
            let privkey = PrivateKey(network: .testnet)
            wallet = Wallet(privateKey: privkey)
            wallet?.save()
        }
    }
    
    func updateLabels() {
        qrCodeImageView.image = wallet?.address.qrImage()
        addressLabel.text = wallet?.address.cashaddr
        if let balance = wallet?.balance() {
            balanceLabel.text = "残高：\(balance) satoshi"
        }
    }
    
    func updateBalance() {
        wallet?.reloadBalance(completion: { [weak self] (utxos) in
            DispatchQueue.main.async { self?.updateLabels() }
        })
    }

    @IBAction func didTapReloadBalanceButton(_ sender: UIButton) {
        updateBalance()
    }
    
    @IBAction func didTapSendButton(_ sender: UIButton) {
        guard let addressString = destinationAddressTextField.text else {
            return
        }
        
        do {
            let address: Address = try AddressFactory.create(addressString)
            try wallet?.send(to: address, amount: 10000, completion: { [weak self] (response) in
                print(response ?? "")
                self?.updateBalance()
            })
        } catch {
            print(error)
        }
    }
}

