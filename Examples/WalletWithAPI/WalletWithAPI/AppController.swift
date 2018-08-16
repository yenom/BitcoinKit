//
//  AppController.swift
//  SampleWallet
//
//  Created by Akifumi Fujita on 2018/08/07.
//  Copyright © 2018年 Akifumi Fujita. All rights reserved.
//

import Foundation
import BitcoinKit
import KeychainAccess

class AppController {
    static let shared = AppController()

    private(set) var wallet: Wallet?

    private init() {
        let keychain = Keychain()
        if let wif = keychain[string: "wif"] {
            wallet = try! Wallet(wif: wif)
            return
        }
    }

    func importWallet(wif: String) {
        let keychain = Keychain()
        keychain[string: "wif"] = wif

        wallet = try! Wallet(wif: wif)
    }
}
