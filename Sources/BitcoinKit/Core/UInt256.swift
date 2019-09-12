//
//  UInt256.swift
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

// UInt256 corresponds to `arith_uint256` in the original bitcoin core.
struct UInt256 {
	enum UInt256Error: Error {
		case invalidDataSize
	}
	public static var max: UInt256 {
		return UInt256(UInt64.max, UInt64.max, UInt64.max, UInt64.max)
	}
	public static var bitWidth: Int { return 256 }
	public static let byteWidth = UInt256.bitWidth / 8
	static let elementCount = byteWidth / 8

	// e0 is lowest digit (UInt64 value is LittleEndian)
	// e3 is highest digit (UInt64 value is LittleEndian)
	private var e0: UInt64
	private var e1: UInt64
	private var e2: UInt64
	private var e3: UInt64

	public static let zero = UInt256()

	init() {
		e0 = 0
		e1 = 0
		e2 = 0
		e3 = 0
	}

	init(_ e0: UInt64, _ e1: UInt64, _ e2: UInt64, _ e3: UInt64) {
		self.e0 = e0
		self.e1 = e1
		self.e2 = e2
		self.e3 = e3
	}

	// 64bytes "01 00 00 00 ... 00"
	// : UInt256(1)
	init?(data: Data) {
		if data.count != UInt256.byteWidth { return nil }
		// little endian cast
		e0 = data[0..<8].to(type: UInt64.self)
		e1 = data[8..<16].to(type: UInt64.self)
		e2 = data[16..<24].to(type: UInt64.self)
		e3 = data[24..<32].to(type: UInt64.self)
	}

	// hex: MSB representation
	// "_" is ignored in parsing
	// UInt256(hex: "00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000001")
	// : UInt256(1)
	init?(hex: String) {
		let h = hex.replacingOccurrences(of: "_", with: "")
		// big endian
		guard let data = Data(hex: h)?.reversed() else { return nil }
		self.init(data: Data(data))
	}

	public init(_ val: UInt) {
		// set to lowest digit
		self = UInt256(UInt64(val), 0, 0, 0)
	}

	public init(_ val: UInt64) {
		self = UInt256(val, 0, 0, 0)
	}

	public init(_ val: UInt32) {
		self = UInt256(UInt64(val))
	}

	public init(_ val: UInt16) {
		self = UInt256(UInt64(val))
	}

	public init(_ val: UInt8) {
		self = UInt256(UInt64(val))
	}
}

extension UInt256: CustomDebugStringConvertible {
	public var debugDescription: String {
		return self.hex
	}
}

extension UInt256: Equatable {
	public static func == (lhs: UInt256, rhs: UInt256) -> Bool {
		if lhs.e0 != rhs.e0 {
            return false
        } else if lhs.e1 != rhs.e1 {
            return false
        } else if lhs.e2 != rhs.e2 {
            return false
        } else if lhs.e3 != rhs.e3 {
            return false
        }
		return true
	}
}

extension UInt256: Comparable {
	public static func < (lhs: UInt256, rhs: UInt256) -> Bool {
		// compare higest digit at first
		if lhs.e3 != rhs.e3 {
            return lhs.e3 < rhs.e3
        } else if lhs.e2 != rhs.e2 {
            return lhs.e2 < rhs.e2
        } else if lhs.e1 != rhs.e1 {
            return lhs.e1 < rhs.e1
        } else if lhs.e0 != rhs.e0 {
            return lhs.e0 < rhs.e0
        }
		// a < a is always false (Irreflexivity)
		return false
	}
}

extension UInt64 {
	// MSB representation
	public var hex: String {
        let high: UInt64 = (self & 0xffffffff00000000) >> 32
        let low: UInt64 = self & 0x00000000ffffffff
        return String(format: "%08x", high) + String(format: "%08x", low)
	}
}

extension UInt256 {
	// MSB representation
	public var hex: String {
		return [e3, e2, e1, e0].map({ $0.hex }).joined(separator: "")
	}
}

extension UInt256 {
    public var data: Data {
		// little endian cast
		return Data(from: e0) + Data(from: e1) + Data(from: e2) + Data(from: e3)
    }
}

protocol BitShiftOperator {
	static func >> <RHS>(lhs: Self, rhs: RHS) -> Self where RHS: UnsignedInteger
	static func << <RHS>(lhs: Self, rhs: RHS) -> Self where RHS: UnsignedInteger
}

extension UInt256: BitShiftOperator {
	public static func >> <RHS>(lhs: UInt256, rhs: RHS) -> UInt256 where RHS: UnsignedInteger {
		if rhs < 64 {
			var v = UInt256()
			let mask = bitValue(bit: UInt(rhs))
			let shift = 64 - rhs
			v.e3 = lhs.e3 >> rhs
			v.e2 = (lhs.e2 >> rhs) + ((lhs.e3 & mask) << shift)
			v.e1 = (lhs.e1 >> rhs) + ((lhs.e2 & mask) << shift)
			v.e0 = (lhs.e0 >> rhs) + ((lhs.e1 & mask) << shift)
			return v
		} else if rhs < 128 {
			var v = UInt256()
			let mask = bitValue(bit: UInt(rhs - 64))
			let shift = 128 - rhs
			v.e3 = 0
			v.e2 = (lhs.e3 >> (rhs - 64))
			v.e1 = (lhs.e2 >> (rhs - 64)) + ((lhs.e3 & mask) << shift)
			v.e0 = (lhs.e1 >> (rhs - 64)) + ((lhs.e2 & mask) << shift)
			return v
		} else if rhs < 192 {
			var v = UInt256()
			let mask = bitValue(bit: UInt(rhs - 128))
			let shift = 192 - rhs
			v.e3 = 0
			v.e2 = 0
			v.e1 = (lhs.e3 >> (rhs - 128))
			v.e0 = (lhs.e2 >> (rhs - 128)) + ((lhs.e3 & mask) << shift)
			return v
		} else if rhs < 256 {
			var v = UInt256()
			v.e3 = 0
			v.e2 = 0
			v.e1 = 0
			v.e0 = (lhs.e3 >> (rhs - 192))
			return v
		} else {
			return UInt256.zero
		}
	}

	public static func << <RHS>(lhs: UInt256, rhs: RHS) -> UInt256 where RHS: UnsignedInteger {
		if rhs < 64 {
			var v = UInt256()
			let rev = rhs
			let shift = 64 - rhs
			v.e3 = (lhs.e3 << rev) + (lhs.e2 >> shift)
			v.e2 = (lhs.e2 << rev) + (lhs.e1 >> shift)
			v.e1 = (lhs.e1 << rev) + (lhs.e0 >> shift)
			v.e0 = (lhs.e0 << rev)
			return v
		} else if rhs < 128 {
			var v = UInt256()
			let rev = rhs - 64
			let shift = 128 - rhs
			v.e3 = (lhs.e2 << rev) + (lhs.e1 >> shift)
			v.e2 = (lhs.e1 << rev) + (lhs.e0 >> shift)
			v.e1 = (lhs.e0 << rev)
			v.e0 = 0
			return v
		} else if rhs < 192 {
			var v = UInt256()
			let rev = rhs - 128
			let shift = 192 - rhs
			v.e3 = (lhs.e1 << rev) + (lhs.e0 >> shift)
			v.e2 = (lhs.e0 << rev)
			v.e1 = 0
			v.e0 = 0
			return v
		} else if rhs < 256 {
			var v = UInt256()
			let rev = rhs - 192
			v.e3 = (lhs.e0 << rev)
			v.e2 = 0
			v.e1 = 0
			v.e0 = 0
			return v
		} else {
			return UInt256.zero
		}
	}
}

private func bitValue(bit: UInt) -> UInt64 {
	var v: UInt64 = 0
	for i in 0 ..< bit {
		v += (1 << i)
	}
	return v
}
