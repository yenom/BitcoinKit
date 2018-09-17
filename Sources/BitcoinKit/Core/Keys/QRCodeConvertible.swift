//
//  QRImageConvertable.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/16.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import UIKit

public protocol QRCodeConvertible {
    var qrcodeString: String { get }
    func qrImage(size: CGSize) -> UIImage?
}

extension QRCodeConvertible {
    public func qrImage(size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        return QRCodeGenerator.generate(from: qrcodeString, size: size)
    }
}

extension CustomStringConvertible where Self: QRCodeConvertible {
    public var qrcodeString: String {
        return description
    }
}
