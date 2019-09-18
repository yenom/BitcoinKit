//
//  Mnemonic+Checksum+Validate.swift
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

public extension Mnemonic {

    static func deriveLanguageFromMnemonic(words: [String]) -> Language? {
        func tryLangauge(
            _ language: Language
        ) -> Language? {
            let vocabulary = Set(wordList(for: language))
            let wordsLeftToCheck = Set(words)

            guard wordsLeftToCheck.intersection(vocabulary) == wordsLeftToCheck else {
                return nil
            }

            return language
        }

        for langauge in Language.allCases {
            guard let derived = tryLangauge(langauge) else { continue }
            return derived
        }
        return nil
    }

    @discardableResult
    static func validateChecksumDerivingLanguageOf(mnemonic mnemonicWords: [String]) throws -> Bool {
        guard let derivedLanguage = deriveLanguageFromMnemonic(words: mnemonicWords) else {
            throw MnemonicError.validationError(.unableToDeriveLanguageFrom(words: mnemonicWords))
        }
        return try validateChecksumOf(mnemonic: mnemonicWords, language: derivedLanguage)
    }

    // https://github.com/mcdallas/cryptotools/blob/master/btctools/HD/__init__.py#L27-L41
    // alternative in C:
    // https://github.com/trezor/trezor-crypto/blob/0c622d62e1f1e052c2292d39093222ce358ca7b0/bip39.c#L161-L179
    @discardableResult
    static func validateChecksumOf(mnemonic mnemonicWords: [String], language: Language) throws -> Bool {
        let vocabulary = wordList(for: language)

        let indices: [UInt11] = try mnemonicWords.map { word in
            guard let indexInVocabulary = vocabulary.firstIndex(of: word) else {
                throw MnemonicError.validationError(.wordNotInList(word, language: language))
            }
            guard let indexAs11Bits = UInt11(exactly: indexInVocabulary) else {
                fatalError("Unexpected error, is word list longer than 2048 words, it shold not be")
            }
            return indexAs11Bits
        }

        let bitArray = BitArray(indices)

        let checksumLength = mnemonicWords.count / 3

        let dataBits = bitArray.prefix(subtractFromCount: checksumLength)
        let checksumBits = bitArray.suffix(maxCount: checksumLength)

        let hash = Crypto.sha256(dataBits.asData())

        let hashBits = BitArray(data: hash).prefix(maxCount: checksumLength)

        guard hashBits == checksumBits else {
            throw MnemonicError.validationError(.checksumMismatch)
        }

        // All is well
        return true
    }
}
