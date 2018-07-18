//
//  AppController.swift
//  Wallet
//
//  Created by Kishikawa Katsumi on 2018/02/05.
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 Shun Usami
//  Copyright © 2018 BitcoinCashKit developers
//  Licensed under the Apache License, Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  This file has been modified by the BitcoinCashKit developers for the BitcoinCashKit project.
//  The original file was from the bitcoinj project (https://github.com/kishikawakatsumi/BitcoinKit).
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

extension Data {
    init?(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hex.index(hex.startIndex, offsetBy: i * 2)
            let k = hex.index(j, offsetBy: 2)
            let bytes = hex[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
    
    var hex: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
}
