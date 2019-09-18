//
//  Mnemonic+Generate.swift
//  BitcoinKit
//
//  Created by Alexander Cyon on 2019-09-18.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import Foundation

// MARK: - Public

#if BitcoinKitXcode
import BitcoinKit.Private
#else
import BitcoinKitPrivate
#endif

// MARK: Generate
public extension Mnemonic {
    static func generate(strength: Strength = .default, language: Language = .english) throws -> [String] {
        let byteCount = strength.rawValue / bitsPerByte
        var bytes = Data(count: byteCount)
        let status = bytes.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, byteCount, $0.baseAddress.unsafelyUnwrapped) }
        guard status == errSecSuccess else { throw MnemonicError.randomBytesError }
        return try generate(entropy: bytes, language: language)
    }
}

internal extension Mnemonic {
    static func generate(
        entropy: Data,
        language: Language = .english
    ) throws -> [String] {

        let words = wordList(for: language)
        let hash = Crypto.sha256(entropy)

        let entropyBinaryString = entropy.binaryString
        let hashBinaryString = hash.binaryString
        let checkSum = String(hashBinaryString.prefix((entropy.count * bitsPerByte) / 32))

        let concatenatedBits = entropyBinaryString + checkSum

        var mnemonic: [String] = []
        for index in 0..<(concatenatedBits.count / wordListSizeLog2) {
            let startIndex = concatenatedBits.index(concatenatedBits.startIndex, offsetBy: index * wordListSizeLog2)
            let endIndex = concatenatedBits.index(startIndex, offsetBy: wordListSizeLog2)
            let wordIndex = Int(strtoul(String(concatenatedBits[startIndex..<endIndex]), nil, 2))
            mnemonic.append(String(words[wordIndex]))
        }

        try validateChecksumOf(mnemonic: mnemonic, language: language)

        return mnemonic
    }
}

// MARK: To Seed
public extension Mnemonic {
    /// Pass a trivial closure: `{ _ in }` to `validateChecksum` if you would like to opt-out of checksum validation.
    static func seed(
        mnemonic words: [String],
        passphrase: String = "",
        validateChecksum: (([String]) throws -> Void) = { try Mnemonic.validateChecksumDerivingLanguageOf(mnemonic: $0) }
    ) rethrows -> Data {

        try validateChecksum(words)

        let mnemonic = words.joined(separator: " ").decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        let salt = ("mnemonic" + passphrase).decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        let seed = _Key.deriveKey(mnemonic, salt: salt, iterations: 2048, keyLength: 64)
        return seed
    }
}

internal func intToBinString<I>(_ int: I) -> String where I: BinaryInteger {
    guard let uint8 = UInt8(exactly: int) else { fatalError("could not create uint8 from integer: \(int)") }
    return byteToBinString(byte: uint8)
}

internal func byteToBinString(byte: UInt8) -> String {
    return String(("00000000" + String(byte, radix: 2)).suffix(8))
}
