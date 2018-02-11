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
    @IBOutlet weak var syncButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Transactions"
    }

    @IBAction func sync(_ sender: UIButton) {
        if let peerGroup = peerGroup {
            peerGroup.stop()
            peerGroup.delegate = nil
            self.peerGroup = nil

            syncButton.setTitle("Sync", for: .normal)
        } else {
            let blockStore = try! SQLiteBlockStore.default()
            let blockChain = BlockChain(wallet: wallet, blockStore: blockStore)

            peerGroup = PeerGroup(blockChain: blockChain)
            peerGroup?.delegate = self

            peerGroup?.start()
            syncButton.setTitle("Stop", for: .normal)
        }
    }

    func peerGroupDidStart(_ peer: PeerGroup) {}
    func peerGroupDidStop(_ peer: PeerGroup) {}
}
