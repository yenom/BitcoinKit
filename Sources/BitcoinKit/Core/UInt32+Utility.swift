//
//  UInt32+Utility.swift
//
//  Copyright © 2018 pebble8888  All rights reserved.
//

import Foundation

extension UInt32 {
	public var hex: String {
		return String(format:"%08x", self)
	}
}
