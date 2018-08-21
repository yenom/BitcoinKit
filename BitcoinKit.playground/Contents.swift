//: Playground - noun: a place where people can play
// No such module "BitcoinKit" error is thrown when you are selecting "Generic iOS Device" as a build target. Please select any of iOS simulators.

import BitcoinKit

// You can try BitcoinKit here
// Lock Script
let lockScript = try! Script()
    .append(.OP_6)
    .append(.OP_ADD)
    .append(.OP_16)
    .append(.OP_EQUAL)

// Unlock Script
let unlockScript = try! Script().appendData(BigNumber(10).data)

// Test [integrated]
let context = ScriptExecutionContext(isDebug: true)
do {
    let result = try ScriptMachine.verify(lockScript: lockScript, unlockScript: unlockScript, context: context)
    print(result ? "Success!" : "Failure")
} catch let error {
    print(error)
}

// Test [unlockScript/lockScript]
context.resetStack()
do {
    try unlockScript.execute(with: context)
    try lockScript.execute(with: context)
    let result = context.bool(at: -1)
    print(result ? "Success!" : "Failure")
} catch let error {
    print(error)
}
