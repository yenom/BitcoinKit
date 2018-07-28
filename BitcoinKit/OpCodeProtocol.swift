//
//  OpCodeProtocol.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/26.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public protocol OpCodeProtocol {
    var name: String { get }
    var value: UInt8 { get }

    func isEnabled() -> Bool
    func execute(_ context: ScriptExecutionContext) throws
}

extension OpCodeProtocol {
    public func isEnabled() -> Bool {
        return true
    }
    public func prepareExecute(_ context: ScriptExecutionContext) throws {
        context.opCount += 1
        guard context.opCount <= BTC_MAX_OPS_PER_SCRIPT else {
            throw ScriptMachineError.error("Exceeded the allowed number of operations per script.")
        }
    }

    public func execute(_ context: ScriptExecutionContext) throws {
        try prepareExecute(context)
        // write something!
    }
}

func == (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Bool {
    return lhs.value == rhs.value
}
func == <Other: BinaryInteger>(lhs: OpCodeProtocol, rhs: Other) -> Bool {
    return lhs.value == rhs
}
func == <Other: BinaryInteger>(lhs: Other, rhs: OpCodeProtocol) -> Bool {
    return lhs == rhs.value
}

func != (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Bool {
    return lhs.value != rhs.value
}
func != <Other: BinaryInteger>(lhs: OpCodeProtocol, rhs: Other) -> Bool {
    return lhs.value != rhs
}
func != <Other: BinaryInteger>(lhs: Other, rhs: OpCodeProtocol) -> Bool {
    return rhs != rhs.value
}

func > (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Bool {
    return lhs.value > rhs.value
}
func > <Other: BinaryInteger>(lhs: OpCodeProtocol, rhs: Other) -> Bool {
    return lhs.value > rhs
}
func > <Other: BinaryInteger>(lhs: Other, rhs: OpCodeProtocol) -> Bool {
    return lhs > rhs.value
}

func < (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Bool {
    return lhs.value < rhs.value
}
func < <Other: BinaryInteger>(lhs: OpCodeProtocol, rhs: Other) -> Bool {
    return lhs.value < rhs
}
func < <Other: BinaryInteger>(lhs: Other, rhs: OpCodeProtocol) -> Bool {
    return lhs < rhs.value
}

func >= (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Bool {
    return lhs.value >= rhs.value
}
func <= (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Bool {
    return lhs.value <= rhs.value
}
func ... (lhs: OpCodeProtocol, rhs: OpCodeProtocol) -> Range<UInt8> {
    return Range(lhs.value...rhs.value)
}

func ~= (pattern: OpCodeProtocol, op: OpCodeProtocol) -> Bool {
    return pattern == op
}
func ~= (pattern: Range<UInt8>, op: OpCodeProtocol) -> Bool {
    return pattern ~= op.value
}

//extension OpCodeProtocol {
//    // ==
//    static func == <Other: OpCodeProtocol>(lhs: Self, rhs: Other) -> Bool {
//        return lhs.value == rhs.value
//    }
//    static func == <Other: BinaryInteger>(lhs: Self, rhs: Other) -> Bool {
//        return lhs.value == rhs
//    }
//    static func == <Other: BinaryInteger>(lhs: Other, rhs: Self) -> Bool {
//        return lhs == rhs.value
//    }
//
//    // !=
//    static func != <Other: OpCodeProtocol>(lhs: Self, rhs: Other) -> Bool {
//        return lhs.value != rhs.value
//    }
//    static func != <Other: BinaryInteger>(lhs: Self, rhs: Other) -> Bool {
//        return lhs.value != rhs
//    }
//    static func != <Other: BinaryInteger>(lhs: Other, rhs: Self) -> Bool {
//        return rhs != rhs.value
//    }
//
//    // <
//    static func < <Other: OpCodeProtocol>(lhs: Self, rhs: Other) -> Bool {
//        return lhs.value < rhs.value
//    }
//    static func < <Other: BinaryInteger>(lhs: Self, rhs: Other) -> Bool {
//        return lhs.value < rhs
//    }
//    static func < <Other: BinaryInteger>(lhs: Other, rhs: Self) -> Bool {
//        return lhs < rhs.value
//    }
//
//    // >
//    static func > <Other: OpCodeProtocol>(lhs: Self, rhs: Other) -> Bool {
//        return lhs.value > rhs.value
//    }
//    static func > <Other: BinaryInteger>(lhs: Self, rhs: Other) -> Bool {
//        return lhs.value > rhs
//    }
//    static func > <Other: BinaryInteger>(lhs: Other, rhs: Self) -> Bool {
//        return lhs > rhs.value
//    }
//
//    // <=
//    static func <= <Other: OpCodeProtocol>(lhs: Self, rhs: Other) -> Bool {
//        return lhs.value <= rhs.value
//    }
//    static func <= <Other: BinaryInteger>(lhs: Self, rhs: Other) -> Bool {
//        return lhs.value <= rhs
//    }
//    static func <= <Other: BinaryInteger>(lhs: Other, rhs: Self) -> Bool {
//        return lhs <= rhs.value
//    }
//
//    // >=
//    static func >= <Other: OpCodeProtocol>(lhs: Self, rhs: Other) -> Bool {
//        return lhs.value >= rhs.value
//    }
//    static func >= <Other: BinaryInteger>(lhs: Self, rhs: Other) -> Bool {
//        return lhs.value >= rhs
//    }
//    static func >= <Other: BinaryInteger>(lhs: Other, rhs: Self) -> Bool {
//        return lhs >= rhs.value
//    }
//}
