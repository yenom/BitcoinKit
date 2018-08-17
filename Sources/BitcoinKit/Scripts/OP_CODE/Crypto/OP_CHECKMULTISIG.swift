//
//  OP_CHECKMULTISIG.swift
//
//  Copyright © 2018 BitcoinKit developers
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

// Compares the first signature against each public key until it finds an ECDSA match. Starting
// with the subsequent public key, it compares the second signature against each remaining public key
// until it finds an ECDSA match. The process is repeated until all signatures have been checked or not
// enough public keys remain to produce a successful result. All signatures need to match a public key.
// Because public keys are not checked again if they fail any signature comparison, signatures must be
// placed in the scriptSig using the same order as their corresponding public keys were placed in the
// scriptPubKey or redeemScript. If all signatures are valid, 1 is returned, 0 otherwise. Due to a bug,
// one extra unused value is removed from the stack.
public struct OpCheckMultiSig: OpCodeProtocol {
    public var value: UInt8 { return 0xae }
    public var name: String { return "OP_CHECKMULTISIG" }

    // input : x sig1 sig2 ... <number of signatures> pub1 pub2 <number of public keys>
    // output : true / false
     public func mainProcess(_ context: ScriptExecutionContext) throws {

        // Get numPublicKeys with validation
        try context.assertStackHeightGreaterThanOrEqual(1)
        let numPublicKeys = Int(try context.number(at: -1))
        guard numPublicKeys >= 0 && numPublicKeys <= BTC_MAX_KEYS_FOR_CHECKMULTISIG else {
            throw OpCodeExecutionError.error("Invalid number of keys for \(name): \(numPublicKeys).")
        }
        try context.incrementOpCount(by: numPublicKeys)
        context.stack.removeLast()

        // Get pubkeys with validation
        var publicKeys: [Data] = []
        try context.assertStackHeightGreaterThanOrEqual(numPublicKeys)
        for _ in 0..<numPublicKeys {
            publicKeys.append(context.stack.removeLast())
        }

        // Get numgSis with validation
        try context.assertStackHeightGreaterThanOrEqual(1)
        let numSigs = Int(try context.number(at: -1))
        guard numSigs >= 0 && numSigs <= numPublicKeys else {
            throw OpCodeExecutionError.error("Invalid number of signatures for \(name): \(numSigs).")
        }
        context.stack.removeLast()

        // Get sigs with validation
        var signatures: [Data] = []
        try context.assertStackHeightGreaterThanOrEqual(numSigs)
        for _ in 0..<numSigs {
            signatures.append(context.stack.removeLast())
        }

        // Remove extra opcode (OP_0)
        // Due to a bug, one extra unused value is removed from the stack.
        try context.assertStackHeightGreaterThanOrEqual(1)
        context.stack.removeLast()

        // Signatures must come in the same order as their keys.
        var success: Bool = true
        var firstSigError: Error?
        guard let tx = context.transaction, let utxo = context.utxoToVerify else {
            throw OpCodeExecutionError.error("The transaction or the utxo to verify is not set.")
        }
        while success && !signatures.isEmpty {
            let pubkeyData: Data = publicKeys.removeFirst()
            let sigData: Data = signatures[0]
            do {
                let valid = try Crypto.verifySigData(for: tx, inputIndex: Int(context.inputIndex), utxo: utxo, sigData: sigData, pubKeyData: pubkeyData)
                if valid {
                    signatures.removeFirst()
                }
            } catch let error {
                if firstSigError == nil {
                    firstSigError = error
                }
            }

            // If there are more signatures left than keys left,
            // then too many signatures have failed
            if publicKeys.count < signatures.count {
                success = false
            }
        }
        context.pushToStack(success)
    }
}
