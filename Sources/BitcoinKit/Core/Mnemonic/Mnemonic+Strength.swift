//
//  Mnemonic+Strength.swift
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

	/// `wordCount` must be divisible by `3`, else `nil` is returned
	init?(wordCount: Int) {
		guard wordCount % Mnemonic.Strength.checksumBitsPerWord == 0 else { return nil }
		let entropyInBitsFromWordCount = (wordCount / Mnemonic.Strength.checksumBitsPerWord) * 32
		self.init(rawValue: entropyInBitsFromWordCount)
	}

	init?(byteCount: Int) {
		let bitCount = byteCount * bitsPerByte
		guard
			let strength = Mnemonic.Strength(rawValue: bitCount)
			else { return nil }
		self = strength
	}
}

// MARK: - Internal

internal extension Mnemonic.Strength {

	static let checksumBitsPerWord = 3

	var byteCount: Int {
		return rawValue / bitsPerByte
	}

	var wordCount: Int {
		return Mnemonic.Strength.wordCountFrom(entropyInBits: rawValue)
	}

	static func wordCountFrom(entropyInBits: Int) -> Int {
		return Int(ceil(Double(entropyInBits) / Double(Mnemonic.WordList.sizeLog2)))
	}

	var checksumLengthInBits: Int {
		return wordCount / Mnemonic.Strength.checksumBitsPerWord
	}
}
