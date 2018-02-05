//
//  ReceiveViewController.swift
//  Wallet
//
//  Created by Kishikawa Katsumi on 2018/02/05.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class ReceiveViewController: UITableViewController, AddressCellDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppController.shared.wallets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressCell
        cell.delegate = self

        let wallet = AppController.shared.wallets[indexPath.row]
        let address = wallet.publicKey.toAddress()
        
        cell.qrCodeImageView.image = generateVisualCode(address: address)
        cell.addressLabel.text = address

        return cell
    }

    public func generateVisualCode(address: String) -> UIImage? {
        let parameters: [String : Any] = [
            "inputMessage": address.data(using: .utf8)!,
            "inputCorrectionLevel": "L"
        ]
        let filter = CIFilter(name: "CIQRCodeGenerator", withInputParameters: parameters)

        guard let outputImage = filter?.outputImage else {
            return nil
        }

        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 6, y: 6))
        guard let cgImage = CIContext().createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    func addressCellGenerateNewAddress(_ addressCell: AddressCell) {
        guard let indexPath = tableView.indexPath(for: addressCell) else {
            return
        }

        let wallet = AppController.shared.wallets[indexPath.row]
        do {
            // FIXME
            let childKey = try wallet.publicKey.derived(at: arc4random_uniform(UInt32.max))
            let address = childKey.toAddress()

            addressCell.qrCodeImageView.image = generateVisualCode(address: address)
            addressCell.addressLabel.text = address
        } catch {}

    }
}

class AddressCell: UITableViewCell {
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!

    weak var delegate: AddressCellDelegate?

    @IBAction func generateNewAddress(_ sender: UIButton) {
        delegate?.addressCellGenerateNewAddress(self)
    }
}

protocol AddressCellDelegate: class {
    func addressCellGenerateNewAddress(_ addressCell: AddressCell)
}
