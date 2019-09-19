//
//  TransactionBuilder.swift
//  
//  Copyright © 2019 BitcoinKit developers
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

/// Helper model that builds an unsigned transaction
/// ```
/// // Builds an unsigned transaction from a transaction plan.
/// let unsignedTx = TransactionBuilder.build(from: plan, toAddress: toAddress, changeAddress: changeAddress)
/// ```
public struct TransactionBuilder {
    /// Builds an unsigned transaction from a transaction plan.
    ///
    /// - Parameters:
    ///   - plan: Transaction plan to build a transaction
    ///   - toAddress: Address to send the amount
    ///   - changeAddress: Address to receive the change
    /// - Returns: The transaction whose inputs are not signed.
    public static func build(from plan: TransactionPlan, toAddress: Address, changeAddress: Address) -> Transaction {
        let toLockScript: Data = Script(address: toAddress)!.data
        var outputs: [TransactionOutput] = [
            TransactionOutput(value: plan.amount, lockingScript: toLockScript)
        ]
        if plan.change > 0 {
            let changeLockScript: Data = Script(address: changeAddress)!.data
            outputs.append(
                TransactionOutput(value: plan.change, lockingScript: changeLockScript)
            )
        }

        let unsignedInputs: [TransactionInput] = plan.unspentTransactions.map {
            TransactionInput(
                previousOutput: $0.outpoint,
                signatureScript: Data(),
                sequence: UInt32.max
            )
        }

        return Transaction(version: 1, inputs: unsignedInputs, outputs: outputs, lockTime: 0)
    }
}
