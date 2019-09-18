//
//  Mnemonic+Wordlist.swift
//  BitcoinKit
//
//  Created by Alexander Cyon on 2019-09-18.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import Foundation

public extension Mnemonic {
    static func wordList(for language: Language) -> [String] {
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
