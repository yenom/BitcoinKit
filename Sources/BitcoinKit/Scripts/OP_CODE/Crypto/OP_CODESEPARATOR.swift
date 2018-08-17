//
//  OP_CODESEPARATOR.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/08/09.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

// All of the signature checking words will only match signatures to the data after the most recently-executed OP_CODESEPARATOR.
public struct OpCodeSeparator: OpCodeProtocol {
    public var value: UInt8 { return 0xab }
    public var name: String { return "OP_CODESEPARATOR" }

    public func mainProcess(_ context: ScriptExecutionContext) throws {
        // do nothing
    }
}
