//
//  ReceiveViewController.swift
//  Wallet
//
//  Created by Kishikawa Katsumi on 2018/02/05.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class ReceiveViewController: UIViewController {
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    @IBAction func copyAddress(_ sender: UIButton) {
        UIPasteboard.general.string = receiveAddress()
    }

    @IBAction func generateNewAddress(_ sender: UIButton) {
        AppController.shared.externalIndex += 1
        updateUI()
    }

    private func generateVisualCode(address: String) -> UIImage? {
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

    func receiveAddress() -> String {
        let wallet = AppController.shared.wallet!
        let externalIndex = AppController.shared.externalIndex
        let address = try! wallet.receiveAddress(index: externalIndex)
        return address.base58
    }

    private func updateUI() {
        qrCodeImageView.image = generateVisualCode(address: receiveAddress())
        addressLabel.text = receiveAddress()
    }
}
