//
//  CreateWalletViewController.swift
//  Wallet
//
//  Created by Kishikawa Katsumi on 2018/02/05.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import BitcoinKit

class CreateWalletViewController: UIViewController {
    var mnemonic: [String]!
    @IBOutlet var mnemonicLabels: [UILabel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            self.mnemonic = try Mnemonic.generate()
            for (mnemonic, label) in zip(mnemonic, mnemonicLabels) {
                label.text = mnemonic
            }
        } catch {
            let alert = UIAlertController(title: "Crypto Error", message: "Failed to generate random seed. Please try again later.", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func createNewWallet(_ sender: UIButton) {
        let seed = Mnemonic.seed(mnemonic: mnemonic)
        AppController.shared.importWallet(seed: seed)

        dismiss()
    }

    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        dismiss()
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
