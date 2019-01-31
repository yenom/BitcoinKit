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
        peerGroup = PeerGroup(network: .testnetBTC, maxConnections: 2)
        peerGroup.start()
    }
}
