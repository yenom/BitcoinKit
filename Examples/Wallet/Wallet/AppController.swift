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

    private(set) var wallets = [HDWallet]()

    func addWallet(_ wallet: HDWallet) {
        wallets.append(wallet)

        if let serialized = try? JSONEncoder().encode(wallets) {
            let keychain = Keychain()
            keychain[data: "wallets"] = serialized
        }

        NotificationCenter.default.post(name: Notification.Name.AppController.walletChanged, object: self)
    }

    private init() {
        let keychain = Keychain()
        if let serialized = keychain[data: "wallets"], let wallets = try? JSONDecoder().decode([HDWallet].self, from: serialized) {
            self.wallets = wallets
        }
    }
}

extension Notification.Name {
    struct AppController {
        static let walletChanged = Notification.Name("AppController.walletChanged")
    }
}
