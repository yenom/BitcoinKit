//
//  Mnemonic+Strength.swift
//  BitcoinKit
//
//  Created by Alexander Cyon on 2019-09-18.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import Foundation

internal let bitsPerByte = 8
internal let wordListSizeLog2 = 11 // 2^11 => 2048

// MARK: Strength
public extension Mnemonic {
    enum Strength: Int, CaseIterable {
        case `default` = 128
        case low = 160
        case medium = 192
        case high = 224
        case veryHigh = 256
    }
}

public extension Mnemonic.Strength {
    init?(wordCount: Int) {
        guard
            let entropyInBitsFromWordCount = Mnemonic.Strength.entropyInBitsFrom(wordCount: wordCount),
            let strength = Self(rawValue: entropyInBitsFromWordCount)
            else { return nil }
        self = strength
    }
}

// MARK: - Internal

internal extension Mnemonic.Strength {
    var wordCount: WordCount {
        let wordCountInt = Mnemonic.Strength.wordCountFrom(entropyInBits: rawValue)
        guard let wordCount = WordCount(rawValue: wordCountInt) else {
            fatalError("Missed to include word count: \(wordCountInt)")
        }
        return wordCount
    }

    static func wordCountFrom(entropyInBits: Int) -> Int {
        return Int(ceil(Double(entropyInBits) / Double(wordListSizeLog2)))
    }

    /// `wordCount` must be divisible by `3`, else `nil` is returned
    static func entropyInBitsFrom(wordCount: Int) -> Int? {
        guard wordCount % Mnemonic.Strength.checksumBitsPerWord == 0 else { return nil }
        return (wordCount / Mnemonic.Strength.checksumBitsPerWord) * 32
    }

    static let checksumBitsPerWord = 3
    var checksumLength: Int {
        return wordCount.wordCount / Mnemonic.Strength.checksumBitsPerWord
    }
}

// MARK: - WordCount
internal extension Mnemonic.Strength {
    enum WordCount: Int {
        case wordCountOf12 = 12
        case wordCountOf15 = 15
        case wordCountOf18 = 18
        case wordCountOf21 = 21
        case wordCountOf24 = 24
    }
}

internal extension Mnemonic.Strength.WordCount {
    var wordCount: Int {
        return rawValue
    }
}
