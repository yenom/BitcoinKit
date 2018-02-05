//
//  HomeViewController.swift
//  Wallet
//
//  Created by Kishikawa Katsumi on 2018/02/05.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import BitcoinKit

class HomeViewController: UITableViewController {
    var wallets = [HDWallet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(walletChanged(notification:)), name: Notification.Name.AppController.walletChanged, object: nil)
    }

    @objc
    func walletChanged(notification: Notification) {
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return AppController.shared.wallets.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "createCell", for: indexPath)
            cell.textLabel?.text = "Create Wallet"
            cell.textLabel?.textAlignment = .center
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "walletCell", for: indexPath)
            cell.textLabel?.text = "Wallet \(indexPath.row + 1)"
            return cell
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? BalanceViewController, let indexPath = tableView.indexPathForSelectedRow {
            let wallet = AppController.shared.wallets[indexPath.row]
            controller.wallet = wallet
        }
    }
}
