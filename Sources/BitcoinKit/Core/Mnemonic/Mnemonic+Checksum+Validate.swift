//
//  Mnemonic+Checksum+Validate.swift
//  BitcoinKit
//
//  Created by Alexander Cyon on 2019-09-18.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
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
