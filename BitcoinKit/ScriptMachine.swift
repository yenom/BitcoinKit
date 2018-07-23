//
//  ScriptMachine.swift
//  BitcoinKit
//
//  Created by Akifumi Fujita on 2018/07/13.
//  Copyright © 2018 Akifumi Fujita
//  Copyright © 2018 BitcoinCashKit developers
//  Licensed under the Apache License, Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  This file has been modified by the BitcoinCashKit developers for the BitcoinCashKit project.
//  The original file was from the bitcoinj project (https://github.com/kishikawakatsumi/BitcoinKit).
//

import Foundation
import secp256k1

enum ScriptVerification {
    case StrictEncoding // enforce strict conformance to DER and SEC2 for signatures and pubkeys (aka SCRIPT_VERIFY_STRICTENC)
    case EvenS // enforce lower S values (below curve halforder) in signatures (aka SCRIPT_VERIFY_EVEN_S, depends on STRICTENC)
}

public enum ScriptMachineError: Error {
    case scriptError(String)
}

// ScriptMachine is a stack machine (like Forth) that evaluates a predicate
// returning a bool indicating valid or not. There are no loops.
// You can -copy a machine which will copy all the parameters and the stack state.
class ScriptMachine {

    // Constants
    private let blobFalse = Data()
    private let blobZero = Data()
    private let blobTrue = Data(bytes: [UInt8(1)])

    // "To" transaction that is signed by an inputScript.
    // Required parameter.
    public var transaction: Transaction?

    // An index of the tx input in the `transaction`.
    // Required parameter.
    public var inputIndex: Int?

    // Overrides inputScript from transaction.inputs[inputIndex].
    // Useful for testing, but useless if you need to test CHECKSIG operations. In latter case you still need a full transaction.
    public var inpuScript: Script?

    // A timestamp of the current block. Default is current timestamp.
    // This is used to test for P2SH scripts or other changes in the protocol that may happen in the future.
    // If not specified, defaults to current timestamp thus using the latest protocol rules.
    public var blockTimestamp: UInt32 = UInt32(NSTimeIntervalSince1970)

    // Flags affecting verification. Default is the most liberal verification.
    // One can be stricter to not relay transactions with non-canonical signatures and pubkey (as BitcoinQT does).
    // Defaults in CoreBitcoin: be liberal in what you accept and conservative in what you send.
    // So we try to create canonical purist transactions but have no problem accepting and working with non-canonical ones.
    public var verificationFlags: ScriptVerification?

    // Stack contains NSData objects that are interpreted as numbers, bignums, booleans or raw data when needed.
    public private(set) var stack = [Data]()

    // Used in ALTSTACK ops.
    public private(set) var altStack = [Data]()

    // Holds an array of @YES and @NO values to keep track of if/else branches.
    private var conditionStack = [Bool]()

    // Currently executed script.
    private var script: Script?

    // Current opcode.
    private var opcode: UInt8 = 0

    // Current payload for any "push data" operation.
    private var pushedData: Data?

    // Current opcode index in _script.
    private var opIndex: Int = 0

    // Index of last OP_CODESEPARATOR
    private var lastCodeSepartorIndex: Int = 0

    // Keeps number of executed operations to check for limit.
    private var opCount: Int = 0

    private var opFailed: Bool = false

    init() {
        stack = [Data()]
        altStack = [Data()]
        conditionStack = [Bool]()
    }

    // This will return nil if the transaction is nil, or inputIndex is out of bounds.
    // You can use -init if you want to run scripts without signature verification (so no transaction is needed).
    convenience init?(tx: Transaction, inputIndex: Int) {
        guard !tx.serialized().isEmpty else {
            return nil
        }

        // BitcoinQT would crash right before VerifyScript if the input index was out of bounds.
        // So even though it returns 1 from SignatureHash() function when checking for this condition,
        // it never actually happens. So we too will not check for it when calculating a hash.
        guard inputIndex < tx.inputs.count else {
            return nil
        }
        self.init()
        self.transaction = tx
        self.inputIndex = inputIndex
    }

    public func resetStack() {
        stack = [Data()]
        altStack = [Data()]
        conditionStack = [Bool]()
    }

    public var shouldVerifyP2SH: Bool {
        return blockTimestamp >= BTC_BIP16_TIMESTAMP
    }

    public func verify(with outputScript: Script?) -> Bool {
        // self.inputScript allows to override transaction so we can simply testing.
        let inputScript: Script

        if let script = self.inpuScript {
            inputScript = script
        } else {
            // Sanity check: transaction and its input should be consistent.
            guard let tx = self.transaction, let inputIndex = self.inputIndex, inputIndex < tx.inputs.count else {
                print("transaction and valid inputIndex are required for script verification.")
                return false
            }
            guard outputScript != nil else {
                print("non-nil outputScript is required for script verification.")
                return false
            }
            let txInput: TransactionInput = tx.inputs[inputIndex]
            guard let script = Script(data: txInput.signatureScript) else {
                return false
            }
            inputScript = script
        }

        // First step: run the input script which typically places signatures, pubkeys and other static data needed for outputScript.
        guard run(script: inputScript) else {
            return false
        }

        // Make a copy of the stack if we have P2SH script.
        // We will run deserialized P2SH script on this stack if other verifications succeed.
        let shouldVerifyP2SH: Bool = self.shouldVerifyP2SH && (outputScript?.isPayToScriptHashScript ?? false)
        let stackForP2SH: [Data]? = shouldVerifyP2SH ? stack : nil

        // Second step: run output script to see that the input satisfies all conditions laid in the output script.
        guard run(script: outputScript) else {
            return false
        }

        // We need to have something on stack
        guard !stack.isEmpty else {
            print("Stack is empty after script execution.")
            return false
        }

        // The last value must be YES.
        guard bool(at: -1) else {
            print("Last item on the stack is boolean NO.")
            return false
        }

        // Additional validation for spend-to-script-hash transactions:
        if shouldVerifyP2SH {
            guard inputScript.isDataOnly else {
                print("Input script for P2SH spending must be literals-only.")
                return false
            }

            guard var stackForP2SH = stackForP2SH, !stackForP2SH.isEmpty else {
                // stackForP2SH cannot be empty here, because if it was the
                // P2SH  HASH <> EQUAL  scriptPubKey would be evaluated with
                // an empty stack and the runScript: above would return NO.
                print("internal inconsistency: stackForP2SH cannot be empty at this point.")
                return false
            }

            // Instantiate the script from the last data on the stack.
            guard let last = stackForP2SH.last, let providedScript = Script(data: last) else {
                print("Script initialization fails")
                return false
            }

            // Remove it from the stack.
            stackForP2SH.removeLast()

            // Replace current stack with P2SH stack.
            resetStack()
            self.stack = stackForP2SH

            guard run(script: providedScript) else {
                return false
            }

            // We need to have something on stack
            guard !stack.isEmpty else {
                print("Stack is empty after script execution.")
                return false
            }

            // The last value must be YES.
            guard bool(at: -1) else {
                print("Last item on the stack is boolean NO.")
                return false
            }
        }

        // If nothing failed, validation passed.
        return true
    }

    public func run(script: Script?) -> Bool {
        guard let script = script else {
            print("non-nil script is required for -runScript:error: method.")
            return false
        }

        guard script.data.count > BTC_MAX_SCRIPT_SIZE else {
            print("Script binary is too long.")
            return false
        }

        // Altstack should be reset between script runs.
        altStack = [Data()]

        opIndex = 0
        opcode = 0
        pushedData = nil
        lastCodeSepartorIndex = 0
        opCount = 0

        opFailed = false
        script.enumerateOperations(block: { [weak self] opIndex, opcode, pushedData -> Bool in
            self?.opIndex = opIndex
            self?.opcode = opcode
            self?.pushedData = pushedData

            guard let result = self?.executeOpcode(), result else {
                opFailed = true
                return true
            }
            return false
        })

        guard !opFailed else {    // QUESTION: 直前で値を代入しているからopFailedはnilでは必ずない。強制アンラップしたい
            return false
        }

        guard conditionStack.isEmpty else {
            print("Condition branches not balanced.")
            return false
        }

        return true
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func executeOpcode() -> Bool {
        guard pushedData == nil || pushedData!.count <= BTC_MAX_SCRIPT_ELEMENT_SIZE else {
            print("Pushdata chunk size is too big.")
            return false
        }

        guard opcode <= Opcode.OP_16 || pushedData != nil || opCount <= BTC_MAX_OPS_PER_SCRIPT else {
            print("Exceeded the allowed number of operations per script.")
            return false
        }

        // Disabled opcodes
        // TODO: update disable opcodes for BCH
        if opcode == Opcode.OP_CAT ||
            opcode == Opcode.OP_SUBSTR ||
            opcode == Opcode.OP_LEFT ||
            opcode == Opcode.OP_RIGHT ||
            opcode == Opcode.OP_INVERT ||
            opcode == Opcode.OP_AND ||
            opcode == Opcode.OP_OR ||
            opcode == Opcode.OP_XOR ||
            opcode == Opcode.OP_2MUL ||
            opcode == Opcode.OP_2DIV ||
            opcode == Opcode.OP_MUL ||
            opcode == Opcode.OP_DIV ||
            opcode == Opcode.OP_MOD ||
            opcode == Opcode.OP_LSHIFT ||
            opcode == Opcode.OP_RSHIFT {
            print("Attempt to execute a disabled opcode.")
            return false
        }

        let shouldExecute: Bool = !conditionStack.contains(false)

        if let pushedData = pushedData, shouldExecute {
            stack.append(pushedData)

        } else if shouldExecute || (Opcode.OP_IF <= opcode && opcode <= Opcode.OP_ENDIF) {
            // this basically means that OP_VERIF and OP_VERNOTIF will always fail the script, even if not executed.

            //
            // Push value
            //
            if opcode == Opcode.OP_1NEGATE ||
                opcode == Opcode.OP_1 ||
                opcode == Opcode.OP_2 ||
                opcode == Opcode.OP_3 ||
                opcode == Opcode.OP_4 ||
                opcode == Opcode.OP_5 ||
                opcode == Opcode.OP_6 ||
                opcode == Opcode.OP_7 ||
                opcode == Opcode.OP_8 ||
                opcode == Opcode.OP_9 ||
                opcode == Opcode.OP_10 ||
                opcode == Opcode.OP_11 ||
                opcode == Opcode.OP_12 ||
                opcode == Opcode.OP_13 ||
                opcode == Opcode.OP_14 ||
                opcode == Opcode.OP_15 ||
                opcode == Opcode.OP_16 {
                // ( -- value)
                let number: Int = Int(opcode) - Int(Opcode.OP_1 - 1)
                stack.append(Data(from: number.littleEndian))
            }

                //
                // Control
                //
            else if opcode == Opcode.OP_NOP ||
                opcode == Opcode.OP_NOP1 ||
                opcode == Opcode.OP_NOP2 ||
                opcode == Opcode.OP_NOP3 ||
                opcode == Opcode.OP_NOP4 ||
                opcode == Opcode.OP_NOP5 ||
                opcode == Opcode.OP_NOP6 ||
                opcode == Opcode.OP_NOP7 ||
                opcode == Opcode.OP_NOP8 ||
                opcode == Opcode.OP_NOP9 ||
                opcode == Opcode.OP_NOP10 ||
                opcode == Opcode.OP_NOP {
                // do nothing
            } else if opcode == Opcode.OP_IF || opcode == Opcode.OP_NOTIF {
                var value: Bool = false
                if shouldExecute {
                    guard stack.count >= 1 else {
                        print("at least one item is needed")
                        return false
                    }
                    value = opcode == Opcode.OP_IF ? bool(at: -1) : !bool(at: -1)
                    stack.removeLast()
                }
                conditionStack.append(value)
            } else if opcode == Opcode.OP_ELSE {
                // Invert last condition.
                guard !conditionStack.isEmpty else {
                    print("Expected an OP_IF or OP_NOTIF branch before OP_ELSE.")
                    return false
                }
                let last = conditionStack.popLast()!
                conditionStack.append(!last)
            } else if opcode == Opcode.OP_ENDIF {
                guard !conditionStack.isEmpty else {
                    print("Expected an OP_IF or OP_NOTIF branch before OP_ENDIF.")
                    return false
                }
                conditionStack.removeLast()
            } else if opcode == Opcode.OP_VERIFY {
                // (true -- ) or
                // (false -- false) and return
                guard stack.count >= 1 else {
                    print("at least one item is needed")
                    return false
                }
                if bool(at: -1) {
                    stack.removeLast()
                } else {
                    print("OP_VERIFY failed.")
                    return false
                }
            } else if opcode == Opcode.OP_RETURN {
                print("OP_RETURN executed.")
                return false
            }

                //
                // Stack ops
                //
            else if opcode == Opcode.OP_TOALTSTACK {
                guard stack.count >= 1 else {
                    print("at least one item is needed")
                    return false
                }
                altStack.append(stack.popLast()!)
            } else if opcode == Opcode.OP_FROMALTSTACK {
                guard altStack.count >= 1 else {
                    print("at least one item is needed")
                    return false
                }
                stack.append(altStack.popLast()!)
            } else if opcode == Opcode.OP_2DROP {
                // (x1 x2 -- )
                guard stack.count >= 2 else {
                    print("at least two items are needed")
                    return false
                }
                stack.removeLast()
                stack.removeLast()
            } else if opcode == Opcode.OP_2DUP {
                // (x1 x2 -- x1 x2 x1 x2)
                guard stack.count >= 2 else {
                    print("at least two items are needed")
                    return false
                }
                stack.append(stack[-2])
                stack.append(stack[-1])
            } else if opcode == Opcode.OP_3DUP {
                // (x1 x2 x3 -- x1 x2 x3 x1 x2 x3)
                guard stack.count >= 3 else {
                    print("at least three items are needed")
                    return false
                }
                stack.append(stack[-3])
                stack.append(stack[-2])
                stack.append(stack[-1])
            } else if opcode == Opcode.OP_2OVER {
                // (x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2)
                guard stack.count >= 4 else {
                    print("at least four items are needed")
                    return false
                }
                stack.append(stack[-4])
                stack.append(stack[-3])
            } else if opcode == Opcode.OP_2ROT {
                // (x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2)
                guard stack.count >= 6 else {
                    print("at least six items are needed")
                    return false
                }
                stack.append(stack.remove(at: -6))
                stack.append(stack.remove(at: -6))
            } else if opcode == Opcode.OP_2SWAP {
                // (x1 x2 x3 x4 -- x3 x4 x1 x2)
                guard stack.count >= 4 else {
                    print("at least four items are needed")
                    return false
                }
                stack.swapAt(-4, -2)
                stack.swapAt(-3, -1)
            } else if opcode == Opcode.OP_IFDUP {
                // (x -- x x)
                // (0 -- 0)
                guard stack.count >= 1 else {
                    print("at least one item are needed")
                    return false
                }
                if bool(at: -1) {
                    stack.append(stack[-1])
                }
            } else if opcode == Opcode.OP_DEPTH {
                // -- stacksize
                let count = stack.count
                stack.append(Data(from: count))
            } else if opcode == Opcode.OP_DUP {
                // (x -- x x)
                guard stack.count >= 1 else {
                    print("at least one item are needed")
                    return false
                }
                stack.append(stack[-1])
            } else if opcode == Opcode.OP_NIP {
                // (x1 x2 -- x2)
                guard stack.count >= 2 else {
                    print("at least two item are needed")
                    return false
                }
                stack.remove(at: -2)
            } else if opcode == Opcode.OP_OVER {
                // (x1 x2 -- x1 x2 x1)
                guard stack.count >= 2 else {
                    print("at least two item are needed")
                    return false
                }
                stack.append(stack[-2])
            } else if opcode == Opcode.OP_PICK || opcode == Opcode.OP_ROLL {
                // pick: (xn ... x2 x1 x0 n -- xn ... x2 x1 x0 xn)
                // roll: (xn ... x2 x1 x0 n --    ... x2 x1 x0 xn)
                guard stack.count >= 2 else {
                    print("at least two items are needed")
                    return false
                }

                // Top item is a number of items to roll over.
                // Take it and pop it from the stack.
                guard let number = number(at: -1) else {
                    return false
                }

                stack.removeLast()

                if number < 0 || number >= stack.count {
                    return false
                }

                let targetIndex = number * -1 - 1
                let data = stack[Int(targetIndex)]
                if opcode == Opcode.OP_ROLL {
                    stack.remove(at: Int(targetIndex))
                }
                stack.append(data)
            } else if opcode == Opcode.OP_ROT {
                // (x1 x2 x3 -- x2 x3 x1)
                //  x2 x1 x3  after first swap
                //  x2 x3 x1  after second swap
                guard stack.count >= 3 else {
                    print("at least three items are needed")
                    return false
                }

                stack.swapAt(-3, -2)
                stack.swapAt(-2, -1)
            } else if opcode == Opcode.OP_SWAP {
                // (x1 x2 -- x2 x1)
                guard stack.count >= 2 else {
                    print("at least two items are needed")
                    return false
                }

                stack.swapAt(-2, -1)
            } else if opcode == Opcode.OP_TUCK {
                // (x1 x2 -- x2 x1 x2)
                guard stack.count >= 2 else {
                    print("at least two items are needed")
                    return false
                }

                stack.insert(stack[-1], at: -3)
            } else if opcode == Opcode.OP_SIZE {
                // (in -- in size)
                guard stack.count >= 1 else {
                    print("at least one item are needed")
                    return false
                }

                let data = stack[-1]
                stack.append(Data(from: data.count))
                //
                // Bitwise logic
                //
            } else if opcode == Opcode.OP_EQUAL || opcode == Opcode.OP_EQUALVERIFY {
                //} else if opcode == OP_NOTEQUAL: // use OP_NUMNOTEQUAL
                // (x1 x2 - bool)
                guard stack.count >= 2 else {
                    print("at least two items are needed")
                    return false
                }

                let x1 = stack.popLast()!
                let x2 = stack.popLast()!
                let equal: Bool = x1 == x2

                // OP_NOTEQUAL is disabled because it would be too easy to say
                // something like n != 1 and have some wiseguy pass in 1 with extra
                // zero bytes after it (numerically, 0x01 == 0x0001 == 0x000001)
                //if (opcode == OP_NOTEQUAL)
                //    equal = !equal;

                if opcode == Opcode.OP_EQUAL {
                    stack.append(equal ? blobTrue : blobFalse)
                } else { // opcode == Opcode.OP_EQUALVERIFY
                    guard equal else {
                        return false
                    }
                }
                //
                // Numeric
                //
            } else if opcode == Opcode.OP_1ADD ||
                opcode == Opcode.OP_1SUB ||
                opcode == Opcode.OP_NEGATE ||
                opcode == Opcode.OP_ABS {
                // (in -- out)
                guard var number = number(at: -1) else {
                    return false
                }
                if opcode == Opcode.OP_1ADD {
                    number += 1
                } else if opcode == Opcode.OP_1SUB {
                    number -= 1
                } else if opcode == Opcode.OP_NEGATE {
                    number *= -1
                } else { // opcode == Opcode.OP_ABS
                    number = number < 0 ? number * -1 : number
                }
                stack.removeLast()
                stack.append(Data(from: number.littleEndian))
            } else if opcode == Opcode.OP_NOT {
                // (in -- out)
                guard let number = number(at: -1) else {
                    return false
                }
                let equal = number == 0 ? blobTrue : blobFalse
                stack.append(equal)
            } else if opcode == Opcode.OP_0NOTEQUAL {
                // (in -- out)
                guard let number = number(at: -1) else {
                    return false
                }
                let equal = number != 0 ? blobTrue : blobFalse
                stack.append(equal)
            } else if opcode == Opcode.OP_ADD || opcode == Opcode.OP_SUB {
                // (x1 x2 -- out)
                guard stack.count >= 2 else {
                    print("at least two items are needed")
                    return false
                }

                guard let number1 = self.number(at: -1), let number2 = self.number(at: -2) else {
                    return false
                }

                var number: Int32

                if opcode == Opcode.OP_ADD {
                    number = number1 + number2
                } else {
                    number = number1 - number2
                }

                stack.removeLast()
                stack.removeLast()
                stack.append(Data(from: number))
            } else if opcode == Opcode.OP_BOOLAND || opcode == Opcode.OP_BOOLAND {
                // (x1 x2 -- out)
                guard stack.count >= 2 else {
                    print("at least two items are needed")
                    return false
                }

                let (bool1, bool2) = (bool(at: -1), bool(at: -2))

                if opcode == Opcode.OP_BOOLAND {
                    stack.append(bool1 && bool2 ? blobTrue : blobFalse)
                } else {
                    stack.append(bool1 || bool2 ? blobTrue : blobFalse)
                }
            } else if opcode == Opcode.OP_NUMEQUAL ||
                opcode == Opcode.OP_NUMEQUALVERIFY ||
                opcode == Opcode.OP_NUMNOTEQUAL ||
                opcode == Opcode.OP_LESSTHAN ||
                opcode == Opcode.OP_GREATERTHAN ||
                opcode == Opcode.OP_LESSTHANOREQUAL ||
                opcode == Opcode.OP_GREATERTHANOREQUAL {
                // (x1 x2 -- out)
                guard stack.count >= 2 else {
                    print("at least two items are needed")
                    return false
                }

                guard let number1 = self.number(at: -1), let number2 = self.number(at: -2) else {
                    return false
                }

                var bool: Bool = false

                if opcode == Opcode.OP_NUMEQUAL || opcode == Opcode.OP_NUMEQUALVERIFY {
                    bool = number1 == number2
                } else if opcode == Opcode.OP_NUMNOTEQUAL {
                    bool = number1 != number2
                } else if opcode == Opcode.OP_LESSTHAN {
                    bool = number1 < number2
                } else if opcode == Opcode.OP_GREATERTHAN {
                    bool = number1 > number2
                } else if opcode == Opcode.OP_LESSTHANOREQUAL {
                    bool = number1 <= number2
                } else { // opcode == opcode.Opcode.OP_GREATERTHANOREQUAL
                    bool = number1 >= number2
                }
                stack.removeLast()
                stack.removeLast()
                if opcode == Opcode.OP_NUMEQUALVERIFY {
                    if !self.bool(at: -1) {
                        return false
                    }
                } else {
                    stack.append(bool ? blobTrue : blobFalse)
                }
            } else if opcode == Opcode.OP_MIN || opcode == Opcode.OP_MAX {
                // (x1 x2 -- out)
                guard stack.count >= 2 else {
                    print("at least two items are needed")
                    return false
                }

                guard let number1 = self.number(at: -1), let number2 = self.number(at: -2) else {
                    return false
                }

                if opcode == Opcode.OP_MIN {
                    stack.append(Data(from: min(number1, number2)))
                } else {
                    stack.append(Data(from: max(number1, number2)))
                }
            } else if opcode == Opcode.OP_WITHIN {
                // (x min max -- out)
                guard stack.count >= 3 else {
                    print("at least three items are needed")
                    return false
                }

                guard let number = self.number(at: -1), let min = self.number(at: -2), let max = self.number(at: -3) else {
                    return false
                }

                let bool = min <= number && number <= max
                stack.append(bool ? blobTrue : blobFalse)
                stack.removeSubrange(Range(-3 ... -1))
            } else if opcode == Opcode.OP_RIPEMD160 ||
                opcode == Opcode.OP_RIPEMD160 ||
                opcode == Opcode.OP_SHA1 ||
                opcode == Opcode.OP_SHA256 ||
                opcode == Opcode.OP_HASH160 ||
                opcode == Opcode.OP_HASH256 {
                // (in -- hash)
                guard stack.count >= 1 else {
                    print("at least one item are needed")
                    return false
                }

                let data: Data = stack.removeLast()
                var hash: Data?

                if opcode == Opcode.OP_RIPEMD160 {
                    hash = Crypto.ripemd160(data)
                } else if opcode == Opcode.OP_SHA1 {
                    assertionFailure("SHA1 is not implemented")
                } else if opcode == Opcode.OP_SHA256 {
                    hash = Crypto.sha256(data)
                } else if opcode == Opcode.OP_HASH160 {
                    assertionFailure("HASH160 is not implemented")
                } else { // opcode == Opcode.OP_HASH256
                    assertionFailure("HASH256 is not implemented")
                }

                stack.append(hash!)
            } else if opcode == Opcode.OP_CODESEPARATOR {
                // Code separator is almost never used and no one knows why it could be useful. Maybe it's Satoshi's design mistake.
                // It affects how OP_CHECKSIG and OP_CHECKMULTISIG compute the hash of transaction for verifying the signature.
                // That hash should be computed after the most recent OP_CODESEPARATOR before current OP_CHECKSIG (or OP_CHECKMULTISIG).
                // Notice how we remember the index of OP_CODESEPARATOR itself, not the position after it.
                // Bitcoind will extract subscript *including* this codeseparator. But all codeseparators will be stripped out eventually
                // when we compute a hash of transaction. Just to keep ourselves close to bitcoind for extra asfety, we'll do the same here.
                lastCodeSepartorIndex = opIndex
            } else if opcode == Opcode.OP_CHECKSIG || opcode == Opcode.OP_CHECKSIGVERIFY {
                // (sig pubkey -- bool)
                guard stack.count >= 2 else {
                    print("at least two items are needed")
                    return false
                }

                let signature: Data = stack.remove(at: -2)
                let pubkeyData: Data = stack.remove(at: -1)

                // Subset of script starting at the most recent OP_CODESEPARATOR (inclusive)
                guard let subScript: Script = script?.subScript(from: lastCodeSepartorIndex) else {
                    return false
                }

                // Drop the signature, since there's no way for a signature to sign itself.
                // Normally we neither have signatures in the output scripts, nor checksig ops in the input scripts.
                // In early days of Bitcoin (before July 2010) input and output scripts were concatenated and executed as one,
                // so this cleanup could make sense. But the concatenation was done with OP_CODESEPARATOR in the middle,
                // so dropping sigs still didn't make much sense - output script was still hashed separately from the input script (that contains signatures).
                // There could have been some use case if one could put a signature
                // right in the output script. E.g. to provably time-lock the funds.
                // But the second tx must contain a valid hash to its parent while
                // the parent must contain a signed hash of its child. This creates an unsolvable cycle.
                // See https://bitcointalk.org/index.php?topic=278992.0 for more info.
                subScript.deleteOccurrences(of: signature)

                // TODO: check wether signature and pukeyData are canonical. Refer to CoreBitcoin

                let transactionOutput = TransactionOutput()
                let success = check(signature: signature, publicKey: pubkeyData, utxoToSign: transactionOutput)

                if opcode == Opcode.OP_CHECKSIGVERIFY {
                    if !success {
                        return false
                    }
                } else {
                    stack.append(success ? blobTrue : blobFalse)
                }
            } else if opcode == Opcode.OP_CHECKMULTISIG || opcode == Opcode.OP_CHECKMULTISIGVERIFY {
                // ([sig ...] num_of_signatures [pubkey ...] num_of_pubkeys -- bool)
                guard stack.count >= 1 else {
                    print("at least one item are needed")
                    return false
                }

                guard var keysCount = number(at: -1) else {
                    return false
                }

                guard keysCount < 0 || keysCount > BTC_MAX_KEYS_FOR_CHECKMULTISIG else {
                    print("invalid number of keys for \(keysCount)")
                    return false
                }

                opCount += Int(keysCount)

                // An index of the first key
                var keyIndex: Int = 2

                // length of stack should be greater than at least sum of the number of keys and signatures
                guard stack.count < keysCount * 2 else {
                    return false
                }

                guard var sigsCount = number(at: Int(-(keysCount + 1))), sigsCount > 0 && sigsCount < keysCount  else {
                    return false
                }

                // The index of the first signature
                var sigIndex: Int = Int(keysCount) + 1 + 1

                let minimumTotalLength: Int = sigIndex + Int(sigsCount)
                guard stack.count > minimumTotalLength else {
                    return false
                }

                // Subset of script starting at the most recent OP_CODESEPARATOR (inclusive)
                guard let subScript = script?.subScript(from: lastCodeSepartorIndex) else {
                    return false
                }

                // Drop the signatures, since there's no way for a signature to sign itself.
                // Essentially this is noop because signatures are never present in scripts.
                // See also a comment to a similar code in OP_CHECKSIG.
                for k in 0..<sigsCount {
                    let sig: Data = stack[-(Int(sigIndex) + Int(k))]
                    _ = subScript.deleteOccurrences(of: sig)
                }

                var success: Bool = true

                // Signatures must come in the same order as their keys.
                while success && sigsCount > 0 {
                    let signature: Data = stack[-sigIndex]
                    let pubkeyData: Data = stack[-keyIndex]

                    // TODO: check wether signature and pukeyData are canonical. Refer to CoreBitcoin

                    let transactionOutput = TransactionOutput()
                    var validMatch: Bool = check(signature: signature, publicKey: pubkeyData, utxoToSign: transactionOutput)

                    if validMatch {
                        sigIndex += 1
                        sigsCount -= 1
                    }

                    keyIndex += 1
                    keysCount -= 1

                    // If there are more signatures left than keys left,
                    // then too many signatures have failed
                    if sigsCount > keysCount {
                        success = false
                    }

                    stack.removeSubrange(Range(-minimumTotalLength - 1 ... -1))

                    if opcode == Opcode.OP_CHECKMULTISIGVERIFY {
                        if !success {
                            return false
                        }
                    } else {
                        stack.append(success ? blobTrue : blobFalse)
                    }
                }
            }
        }
        guard stack.count + altStack.count <= 1000 else {
            return false
        }
        return true
    }

    public func check(signature: Data, publicKey: Data, utxoToSign: TransactionOutput) -> Bool {
        // TODO: can switch to both network
        let pubKey = PublicKey(bytes: publicKey, network: .mainnet)

        // Hash type is one byte tacked on to the end of the signature. So the signature shouldn't be empty.
        guard !signature.isEmpty else {
            return false
        }

        // Extract hash type from the last byte of the signature.
        print("signature", signature.hex)
        let hashType = SighashType(signature.last!)
        print("hashType", hashType)

        // Strip that last byte to have a pure signature.
        let pureSignature = signature.subdata(in: Range(0..<signature.count - 1))
        print("pureSignature", pureSignature.hex, pureSignature)

        guard let transaction = self.transaction, let inputIndex = self.inputIndex else {
            return false
        }

        let sighash: Data = transaction.signatureHash(for: utxoToSign, inputIndex: inputIndex, hashType: hashType)
        print("sighash", sighash.hex, sighash)

        let ctx2 = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_NONE))

        //        let normalized = sighash.withUnsafeBytes { secp256k1_ecdsa_signature_normalize(ctx2!, nil, $0) }
        //        print("normalized", normalized)

        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY))!

        let status = sighash.withUnsafeBytes { (uint8Ptr: UnsafePointer<UInt8>) in
            pubKey.raw.withUnsafeBytes { pubkeyPtr in pureSignature.withUnsafeBytes { secp256k1_ecdsa_verify(ctx, $0, uint8Ptr, pubkeyPtr) }
            }
        }

        print("STATUS", status)

        guard status == 1 else {
            return false
        }

        return true
    }

    private func number(at index: Int) -> Int32? {
        let data: Data = stack[index]
        return Int32(data.withUnsafeBytes { $0.pointee })
    }

    private func bool(at index: Int) -> Bool {
        let data: Data = stack[index]
        guard !data.isEmpty else {
            return false
        }

        for d in data {
            // Can be negative zero, also counts as NO
            if d != 0 && !(d == data.count - 1 && d == (0x80)) {
                return true
            }
        }
        return false
    }
}
