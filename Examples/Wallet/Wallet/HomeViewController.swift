//
//  HomeViewController.swift
//  Wallet
//
//  Created by Kishikawa Katsumi on 2018/02/05.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import BitcoinKit

class HomeViewController: UITableViewController, PeerGroupDelegate {
    var peerGroup: PeerGroup?
    var payments = [Payment]()

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var syncButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(walletChanged(notification:)), name: Notification.Name.AppController.walletChanged, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBalance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let _ = AppController.shared.wallet else {
            performSegue(withIdentifier: "createWallet", sender: self)
            return
        }
    }

    @IBAction func sync(_ sender: UIButton) {
        if let peerGroup = peerGroup {
            peerGroup.stop()
            syncButton.setTitle("Sync", for: .normal)
        } else {
            let blockStore = try! SQLiteBlockStore.default()
            let blockChain = BlockChain(network: AppController.shared.network, blockStore: blockStore)

            peerGroup = PeerGroup(blockChain: blockChain)
            peerGroup?.delegate = self

            for address in usedAddresses() {
                if let publicKey = address.publicKey {
                    peerGroup?.addPublickey(publicKey: publicKey)
                }
                peerGroup?.addPublickey(publicKey: address.publicKeyHash)
            }

            peerGroup?.start()
            syncButton.setTitle("Stop", for: .normal)
        }
    }

    @objc
    func walletChanged(notification: Notification) {
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Transactions"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)

        let peymant = payments[indexPath.row]
        cell.textLabel?.text = "Received: \(peymant.amount)"

        return cell
    }

    func peerGroupDidStop(_ peerGroup: PeerGroup) {
        peerGroup.delegate = nil
        self.peerGroup = nil
    }
    
    func peerGroupDidReceiveTransaction(_ peerGroup: PeerGroup) {
        updateBalance()
    }

    private func usedAddresses() -> [Address] {
        var addresses = [Address]()
        let wallet = AppController.shared.wallet
        for index in 0..<(AppController.shared.externalIndex + 20) {
            if let address = try? wallet!.receiveAddress(index: index) {
                addresses.append(address)
            }
        }
        for index in 0..<(AppController.shared.internalIndex + 20) {
            if let address = try? wallet!.changeAddress(index: index) {
                addresses.append(address)
            }
        }
        return addresses
    }

    func transactions() -> [Payment] {
        let blockStore = try! SQLiteBlockStore.default()

        var payments = [Payment]()
        for address in usedAddresses() {
            payments.append(contentsOf: try! blockStore.transactions(address: address))
        }
        return payments
    }

    private func updateBalance() {
        let blockStore = try! SQLiteBlockStore.default()

        var balance: Int64 = 0
        for address in usedAddresses() {
            balance += try! blockStore.calculateBlance(address: address)
        }

        let decimal = Decimal(balance)
        balanceLabel.text = "\(decimal / Decimal(100000000)) BTC"

        payments = transactions()
        tableView.reloadData()
    }
}
