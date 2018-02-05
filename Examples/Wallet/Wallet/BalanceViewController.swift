//
//  BalanceViewController.swift
//  Wallet
//
//  Created by Kishikawa Katsumi on 2018/02/05.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import BitcoinKit

class BalanceViewController: UITableViewController, PeerGroupDelegate {
    var peerGroup: PeerGroup?
    var wallet: WalletProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Transactions"
    }

    @IBAction func sync(_ sender: UIButton) {
        let blockStore = try! SQLiteBlockStore.default()
        let blockChain = BlockChain(wallet: wallet, blockStore: blockStore)

        peerGroup = PeerGroup(blockChain: blockChain)
        peerGroup?.delegate = self

        peerGroup?.start()
    }

    func peerGroupDidStart(_ peer: PeerGroup) {}
    func peerGroupDidStop(_ peer: PeerGroup) {}
}
