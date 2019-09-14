//
//  UInt11.swift
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

struct UInt11: ExpressibleByIntegerLiteral {

	private let valueBoundBy16Bits: UInt16

	init?(valueBoundBy16Bits: UInt16) {
		if valueBoundBy16Bits > UInt11.max16 {
			return nil
		}
		self.valueBoundBy16Bits = valueBoundBy16Bits
	}
}

// MARK: - Static min/max
extension UInt11 {
	static var bitWidth: Int { return 11 }
	static var max16: UInt16 { return UInt16(2047) }
	static var max: UInt11 { return UInt11(exactly: max16)! }
	static var min: UInt11 { return 0 }
}

// MARK: - Convenience Init
extension UInt11 {

	init?<T>(exactly source: T) where T: BinaryInteger {
		guard let valueBoundBy16Bits = UInt16(exactly: source) else { return nil }
		self.init(valueBoundBy16Bits: valueBoundBy16Bits)
	}

	init<T>(truncatingIfNeeded source: T) where T: BinaryInteger {
		let valueBoundBy16Bits = UInt16(truncatingIfNeeded: source)
		self.valueBoundBy16Bits = Swift.min(UInt11.max16, valueBoundBy16Bits)
	}

	/// Creates a new integer value from the given string and radix.
	init?<S>(_ text: S, radix: Int = 10) where S: StringProtocol {
		guard let uint16 = UInt16(text, radix: radix) else { return nil }
		self.init(valueBoundBy16Bits: uint16)
	}

	init(integerLiteral value: Int) {
		guard let exactly = UInt11(exactly: value) else {
			fatalError("bad integer literal value does not fit in UInt11, value passed was: \(value)")
		}
		self = exactly
	}

	init?(bitArray: BitArray) {
		if bitArray.count > UInt11.bitWidth { return nil }
		self.init(bitArray.binaryString, radix: 2)
	}
}

extension UInt11 {
	var binaryString: String {
		let binaryString = String(valueBoundBy16Bits.binaryString.suffix(UInt11.bitWidth))
		assert(UInt16(binaryString, radix: 2)! == valueBoundBy16Bits, "incorrect conversion.")
		return binaryString
	}

	var asInt: Int {
		return Int(valueBoundBy16Bits)
	}
}
