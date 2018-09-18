//
//  QRCodeGenerator.swift
//
//  Copyright © 2018 BitcoinKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if os(iOS) || os(tvOS) || os(watchOS)
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
#endif
