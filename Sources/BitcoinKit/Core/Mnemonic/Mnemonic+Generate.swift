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
        let entropy = try securelyGenerateBytes(count: strength.byteCount)
        return try generate(entropy: entropy, language: language)
    }
}

internal extension Mnemonic {
    static func generate(
        entropy: Data,
        language: Language = .english
    ) throws -> [String] {

        guard let strength = Mnemonic.Strength(byteCount: entropy.count) else {
            throw Error.unsupportedByteCountOfEntropy(got: entropy.count)
        }

        let words = wordList(for: language)
        let hash = Crypto.sha256(entropy)

        let checkSumBit = BitArray(data: hash).prefix(strength.checksumLengthInBits)

        let bits = BitArray(data: entropy) + checkSumBit

        let wordIndices = bits.splitIntoChunks(ofSize: wordListSizeLog2)
            .map { UInt11(bitArray: $0)! }
            .map { $0.asInt }

        let mnemonic = wordIndices.map { words[$0] }

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
