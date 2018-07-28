//
//  OP_CHECKSIG.swift
//  BitcoinCashKit
//
//  Created by Shun Usami on 2018/07/27.
//  Copyright © 2018 BitcoinCashKit developers. All rights reserved.
//

import Foundation

// The entire transaction's outputs, inputs, and script (from the most recently-executed OP_CODESEPARATOR to the end) are hashed. The signature used by OP_CHECKSIG must be a valid signature for this hash and public key. If it is, 1 is returned, 0 otherwise.
public struct OpCheckSig: OpCodeProtocol {
    public var value: UInt8 { return 0xac }
    public var name: String { return "OP_CHECKSIG" }

    // input : sig pubkey
    // output : true / false
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
    }
}
