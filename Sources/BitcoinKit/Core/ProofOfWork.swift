//
//  ProofOfWork.swift
//
//  Copyright © 2018 pebble8888  All rights reserved.
//

import Foundation

class ProofOfWork {
	static let maxProofOfWork: UInt256
		= UInt256(data: Data(hex:"00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff")!)!
	static func isValidProofOfWork(blockHash: Data, bits: UInt32) -> Bool {
		let target: UInt256
		do {
			target = try UInt256(compact: bits)
		} catch {
			// invalid bits
			return false
		}
		if target == UInt256.zero {
			// invalid zero target
			return false
		}
		if target > maxProofOfWork {
			// too high target
			return false
		}
		guard let arith_hash = UInt256(data: blockHash) else {
			// invalid blockHash data length
			return false
		}
		if arith_hash > target {
			// insufficient proof of work
			return false
		}
		return true
	}
}
