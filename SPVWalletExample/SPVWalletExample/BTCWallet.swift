//
//  BTCWallet.swift
//  SPVWalletExample
//
//  Created by Akifumi Fujita on 2019/01/27.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import Foundation
import BitcoinKit

class BTCWallet {
    static let shared = BTCWallet()
    let peerGroup: PeerGroup!
    
    private init() {
        let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("DB Path: \(dbPath)")
        
        let database = try! SQLiteDatabase.default()
        peerGroup = PeerGroup(database: database, network: .testnetBTC, maxConnections: 2)
        peerGroup.start()
    }
}
