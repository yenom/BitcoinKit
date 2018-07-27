//
//  OP_CHECKSIG.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinKit-cash developers. All rights reserved.
//

import Foundation

public class OpCheckSig: OpCode {
    override public var value: UInt8 { return 0xac }
    override public var name: String { return "OP_CHECKSIGVERIFY" }

    override public func execute(_ context: ScriptExecutionContext) throws {
        try super.execute(context)
        guard context.stack.count >= 2 else {
            throw ScriptMachineError.opcodeRequiresItemsOnStack(2)
        }
        print("stack: \(context.stack.map { $0.hex }.joined(separator: " "))")

        let pubkeyData: Data = context.stack.removeLast()
        let sigData: Data = context.stack.removeLast()

        // Subset of script starting at the most recent OP_CODESEPARATOR (inclusive)
        let subScript = context.script.subScript(from: context.lastCodeSepartorIndex)
        subScript.deleteOccurrences(of: sigData)

        guard let tx = context.transaction, let utxo = context.utxoToVerify else {
            throw ScriptMachineError.error("The transaction or the utxo to verify is not set.")
        }
        let valid = try Crypto.verifySigData(for: tx, inputIndex: Int(context.inputIndex), utxo: utxo, sigData: sigData, pubKeyData: pubkeyData)
        context.pushToStack(valid)
    }
}
