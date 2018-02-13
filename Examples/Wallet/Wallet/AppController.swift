//
//  AppController.swift
//  Wallet
//
//  Created by Kishikawa Katsumi on 2018/02/05.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation
import BitcoinKit
import KeychainAccess

class AppController {
    static let shared = AppController()

    let network = Network.testnet

    private(set) var wallet: HDWallet? {
        didSet {
            NotificationCenter.default.post(name: Notification.Name.AppController.walletChanged, object: self)
        }
    }

    var internalIndex: UInt32 {
        set {
            UserDefaults.standard.set(Int(newValue), forKey: #function)
        }
        get {
            return UInt32(UserDefaults.standard.integer(forKey: #function))
        }
    }
    var externalIndex: UInt32 {
        set {
            UserDefaults.standard.set(Int(newValue), forKey: #function)
        }
        get {
            return UInt32(UserDefaults.standard.integer(forKey: #function))
        }
    }

    private init() {
        let keychain = Keychain()
        if let seed = keychain[data: "seed"] {
            self.wallet = HDWallet(seed: seed, network: network)
        }
    }

    func importWallet(seed: Data) {
        let keychain = Keychain()
        keychain[data: "seed"] = seed

        self.wallet = HDWallet(seed: seed, network: network)
    }
}

extension Notification.Name {
    struct AppController {
        static let walletChanged = Notification.Name("AppController.walletChanged")
    }
}
