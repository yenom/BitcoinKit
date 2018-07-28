//
//  OP_CHECKSIGVERIFY.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/28.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

// Same as OP_CHECKSIG, but OP_VERIFY is executed afterward.
public struct OpCheckSigVerify: OpCodeProtocol {
    public var value: UInt8 { return 0xad }
    public var name: String { return "OP_CHECKSIGVERIFY" }

    // input : sig pubkey
    // output : Nothing / fail
    public func execute(_ context: ScriptExecutionContext) throws {
        try prepareExecute(context)
        guard context.stack.count >= 2 else {
            throw OpCodeExecutionError.opcodeRequiresItemsOnStack(2)
        }

        let pubkeyData: Data = context.stack.removeLast()
        let sigData: Data = context.stack.removeLast()

        // Subset of script starting at the most recent OP_CODESEPARATOR (inclusive)
        let subScript = context.script.subScript(from: context.lastCodeSepartorIndex)
        subScript.deleteOccurrences(of: sigData)

        guard let tx = context.transaction, let utxo = context.utxoToVerify else {
            throw OpCodeExecutionError.error("The transaction or the utxo to verify is not set.")
        }
        let valid = try Crypto.verifySigData(for: tx, inputIndex: Int(context.inputIndex), utxo: utxo, sigData: sigData, pubKeyData: pubkeyData)
        context.pushToStack(valid)

        guard valid else {
            throw OpCodeExecutionError.error("OP_CHECKSIGVERIFY failed.")
        }
        context.stack.removeLast()
    }
}
