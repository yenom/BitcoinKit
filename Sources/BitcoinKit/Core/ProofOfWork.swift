//
//  ProofOfWork.swift
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

class ProofOfWork {
	static let maxProofOfWork: UInt256
		= UInt256(data: Data(hex: "00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff")!)!
	static func isValidProofOfWork(blockHash: Data, bits: UInt32) -> Bool {
		let target: UInt256
		do {
			target = try UInt256(compact: bits)
		} catch {
			// invalid bits
			return false
		}
		guard target != UInt256.zero else {
			// invalid zero target
			return false
		}
		guard target <= maxProofOfWork else {
			// too high target
			return false
		}
		guard let arith_hash = UInt256(data: blockHash) else {
			// invalid blockHash data length
			return false
		}
		guard arith_hash <= target else {
			// insufficient proof of work
			return false
		}
		return true
	}
}
