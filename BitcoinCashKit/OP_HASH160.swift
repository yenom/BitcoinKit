//
//  OP_HASH160.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

// The input is hashed twice: first with SHA-256 and then with RIPEMD-160.
public struct OpHash160: OpCodeProtocol {
    public var value: UInt8 { return 0xa9 }
    public var name: String { return "OP_HASH160" }

    // input : in
    // output : hash
    public func execute(_ context: ScriptExecutionContext) throws {
        try prepareExecute(context)
        guard context.stack.count >= 1 else {
            throw OpCodeExecutionError.opcodeRequiresItemsOnStack(1)
        }

        let data: Data = context.stack.removeLast()
        let hash: Data = Crypto.sha256ripemd160(data)
        context.stack.append(hash)
    }
}
