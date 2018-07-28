//
//  Mnemonic.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/04.
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 Shun Usami
//  Copyright © 2018 BitcoinCashKit developers
//  Licensed under the Apache License, Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  This file has been modified by the BitcoinCashKit developers for the BitcoinCashKit project.
//  The original file was from the bitcoinj project (https://github.com/kishikawakatsumi/BitcoinKit).
//

import Foundation
import BitcoinKit.Private

public struct Mnemonic {
    public enum Strength: Int {
        case `default` = 128
        case low = 160
        case medium = 192
        case high = 224
        case veryHigh = 256
    }

    public enum Language {
        case english
        case japanese
        case korean
        case spanish
        case simplifiedChinese
        case traditionalChinese
        case french
        case italian
    }

    public static func generate(strength: Strength = .default, language: Language = .english) throws -> [String] {
        let byteCount = strength.rawValue / 8
        var bytes = Data(count: byteCount)
        let status = bytes.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, byteCount, $0) }
        guard status == errSecSuccess else { throw MnemonicError.randomBytesError }
        return generate(entropy: bytes, language: language)
    }

    static func generate(entropy: Data, language: Language = .english) -> [String] {
        let list = wordList(for: language)
        var bin = String(entropy.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })

        let hash = Crypto.sha256(entropy)
        let bits = entropy.count * 8
        let cs = bits / 32

        let hashbits = String(hash.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        let checksum = String(hashbits.prefix(cs))
        bin += checksum

        var mnemonic = [String]()
        for i in 0..<(bin.count / 11) {
            let wi = Int(bin[bin.index(bin.startIndex, offsetBy: i * 11)..<bin.index(bin.startIndex, offsetBy: (i + 1) * 11)], radix: 2)!
            mnemonic.append(String(list[wi]))
        }
        return mnemonic
    }

    public static func seed(mnemonic m: [String], passphrase: String = "") -> Data {
        let mnemonic = m.joined(separator: " ").decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        let salt = ("mnemonic" + passphrase).decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        let seed = _Key.deriveKey(mnemonic, salt: salt, iterations: 2048, keyLength: 64)
        return seed
    }

    private static func wordList(for language: Language) -> [String.SubSequence] {
        switch language {
        case .english:
            return WordList.english
        case .japanese:
            return WordList.japanese
        case .korean:
            return WordList.korean
        case .spanish:
            return WordList.spanish
        case .simplifiedChinese:
            return WordList.simplifiedChinese
        case .traditionalChinese:
            return WordList.traditionalChinese
        case .french:
            return WordList.french
        case .italian:
            return WordList.italian
        }
    }
}

public enum MnemonicError: Error {
    case randomBytesError
}
