//
//  UInt32+Math.swift
//
//  Copyright © 2018 pebble8888  All rights reserved.
//

import Foundation

func ceil_log2(_ x: UInt32) -> UInt32 {
	if x == 0 { return 0 }
	var xx = x
	var r: UInt32 = (xx & (xx-1)) != 0 ? 1 : 0
	while true {
		xx >>= 1
		if xx == 0 { break }
		r += 1
	}
	return r
}
