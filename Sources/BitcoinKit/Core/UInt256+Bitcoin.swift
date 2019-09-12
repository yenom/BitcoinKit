//
//  UInt256+Bitcoin.swift
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

extension UInt256 {
	public enum CompactError: Error {
		case negative, overflow
	}
	// bitcoin "compact" format
	public init(compact: UInt32) throws {
		let size: UInt32 = compact >> 24
		let target: UInt32 = compact & 0x007fffff
		if target == 0 {
			self = UInt256.zero
		} else {
    		// The 0x00800000 denotes the sign
    		if (compact & 0x00800000) != 0 {
    			throw CompactError.negative
    		}
    		if size > 0x22 || (target > 0xff && size > 0x21) || (target > 0xffff && size > 0x20) {
    			throw CompactError.overflow
    		}
    		if size < 3 {
    			self = UInt256(target) >> ((3 - size) * 8)
    		} else {
    			self = UInt256(target) << ((size - 3) * 8)
    		}
		}
	}
}
