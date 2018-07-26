//
//  OpCodeProtocol.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/26.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public protocol OP_CODE {
    func isEnabled() -> Bool
    func execute(_ context: ScriptExecutionContext) throws
}

public class ScriptExecutionContext {
    public fileprivate(set) var stack = [Data]()
    public fileprivate(set) var altStack = [Data]()
    private var conditionStack = [Bool]()

    private var opCount: Int = 0
    private var lastCodeSepartorIndex: Int = 0

    // Getters and setter...
}

// swiftlint:disable:next type_name
public struct OP_EXAMPLE: OP_CODE {
    public func isEnabled() -> Bool {
        return true
    }

    public func execute(_ context: ScriptExecutionContext) throws {
        // do something with context here!
    }
}

// swiftlint:disable:next type_name
public struct OP_ {
    public static let EXAMPLE = OP_EXAMPLE()
}
