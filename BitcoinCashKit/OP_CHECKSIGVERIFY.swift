//
//  OP_CHECKSIGVERIFY.swift
//
//  Copyright © 2018 BitcoinCashKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
        let subScript = try context.script.subScript(from: context.lastCodeSepartorIndex)
        try subScript.deleteOccurrences(of: sigData)

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
