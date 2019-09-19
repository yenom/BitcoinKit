//
//  Mnemonic+Generate.swift
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

        let checkSumBits = BitArray(data: hash).prefix(strength.checksumLengthInBits)

        let bits = BitArray(data: entropy) + checkSumBits

		let wordIndices = bits.splitIntoChunks(ofSize: Mnemonic.WordList.sizeLog2)
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
