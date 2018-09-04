//
//  UInt256+bitcoin.swift
//
//  Copyright © 2018 pebble8888  All rights reserved.
//

import Foundation

extension UInt256 {
	public enum CompactError: Error  {
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
