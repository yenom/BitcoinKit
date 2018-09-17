//
//  QRCodeGenerator.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/17.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import UIKit

public struct QRCodeGenerator {
    private static func generateCGImage(from string: String) -> CGImage? {
        let parameters: [String: Any] = [
            "inputMessage": string.data(using: .utf8)!,
            "inputCorrectionLevel": "L"
        ]
        guard let image = CIFilter(name: "CIQRCodeGenerator", withInputParameters: parameters)?.outputImage else {
            return nil
        }

        return CIContext(options: nil).createCGImage(image, from: image.extent)
    }

    private static func generateNonInterpolatedUIImage(from cgImage: CGImage, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.interpolationQuality = .none
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return uiImage
    }

    public static func generate(from string: String, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        guard let cgImage: CGImage = generateCGImage(from: string) else { return nil }
        guard let uiImage: UIImage = generateNonInterpolatedUIImage(from: cgImage, size: size) else { return nil }
        return uiImage
    }
}
