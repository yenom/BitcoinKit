//
//  ScriptFactory.swift
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

public struct ScriptFactory {
    public struct Standard {}
    public struct LockTime {}
    public struct MultiSig {}
    public struct OpReturn {}
    public struct Condition {}
    public struct HashedTimeLockedContract {}
}

// MARK: - Standard
public extension ScriptFactory.Standard {
    public static func buildP2PK(publickey: PublicKey) -> Script? {
        return try? Script()
            .appendData(publickey.raw)
            .append(.OP_CHECKSIG)
    }

    public static func buildP2PKH(address: Address) -> Script? {
        return Script(address: address)
    }

    public static func buildP2SH(script: Script) -> Script {
        return script.toP2SH()
    }

    public static func buildMultiSig(publicKeys: [PublicKey]) -> Script? {
        return Script(publicKeys: publicKeys, signaturesRequired: UInt(publicKeys.count))
    }
    public static func buildMultiSig(publicKeys: [PublicKey], signaturesRequired: UInt) -> Script? {
        return Script(publicKeys: publicKeys, signaturesRequired: signaturesRequired)
    }
}

// MARK: - LockTime
public extension ScriptFactory.LockTime {
    // Base
    public static func build(script: Script, lockDate: Date) -> Script? {
        return try? Script()
            .appendData(lockDate.bigNumData)
            .append(.OP_CHECKLOCKTIMEVERIFY)
            .append(.OP_DROP)
            .appendScript(script)
    }
    
    public static func build(script: Script, lockIntervalSinceNow: TimeInterval) -> Script? {
        let lockDate = Date(timeIntervalSinceNow: lockIntervalSinceNow)
        return build(script: script, lockDate: lockDate)
    }

    // P2PKH + LockTime
    public static func build(address: Address, lockIntervalSinceNow: TimeInterval) -> Script? {
        guard let p2pkh = Script(address: address) else {
            return nil
        }
        let lockDate = Date(timeIntervalSinceNow: lockIntervalSinceNow)
        return build(script: p2pkh, lockDate: lockDate)
    }

    public static func build(address: Address, lockDate: Date) -> Script? {
        guard let p2pkh = Script(address: address) else {
            return nil
        }
        return build(script: p2pkh, lockDate: lockDate)
    }
}

// MARK: - OpReturn
public extension ScriptFactory.OpReturn {
    public static func build(text: String) -> Script? {
        let MAX_OP_RETURN_DATA_SIZE: Int = 220
        guard let data = text.data(using: .utf8), data.count <= MAX_OP_RETURN_DATA_SIZE else {
            return nil
        }
        return try? Script()
            .append(.OP_RETURN)
            .appendData(data)
    }
}

// MARK: - Condition
public extension ScriptFactory.Condition {
    public static func build(scripts: [Script]) -> Script? {

        guard !scripts.isEmpty else {
            return nil
        }
        guard scripts.count > 1 else {
            return scripts[0]
        }

        var scripts: [Script] = scripts

        while scripts.count > 1 {
            var newScripts: [Script] = []
            while !scripts.isEmpty {
                let script = Script()
                do {
                    if scripts.count == 1 {
                        try script
                            .append(.OP_DROP)
                            .appendScript(scripts.removeFirst())
                    } else {
                        try script
                            .append(.OP_IF)
                            .appendScript(scripts.removeFirst())
                            .append(.OP_ELSE)
                            .appendScript(scripts.removeFirst())
                            .append(.OP_ENDIF)
                    }
                } catch {
                    return nil
                }
                newScripts.append(script)
            }
            scripts = newScripts
        }

        return scripts[0]
    }
}

// MARK: - HTLC
public extension ScriptFactory.HashedTimeLockedContract {
    // Base
    public static func build(recipient: Address, sender: Address, lockDate: Date, hash: Data, hashOp: HashOperator) -> Script? {
        guard hash.count == hashOp.hashSize else {
            return nil
        }
        
        return try? Script()
            .append(.OP_IF)
                .append(hashOp.opcode)
                .appendData(hash)
                .append(.OP_EQUALVERIFY)
                .append(.OP_DUP)
                .append(.OP_HASH160)
                .appendData(recipient.data)
            .append(.OP_ELSE)
                .appendData(lockDate.bigNumData)
                .append(.OP_CHECKLOCKTIMEVERIFY)
                .append(.OP_DROP)
                .append(.OP_DUP)
                .append(.OP_HASH160)
                .appendData(sender.data)
            .append(.OP_ENDIF)
            .append(.OP_EQUALVERIFY)
            .append(.OP_CHECKSIG)
    }
    
    // convenience
    public static func build(recipient: Address, sender: Address, lockIntervalSinceNow: TimeInterval, hash: Data, hashOp: HashOperator) -> Script? {
        let lockDate = Date(timeIntervalSinceNow: lockIntervalSinceNow)
        return build(recipient: recipient, sender: sender, lockDate: lockDate, hash: hash, hashOp: hashOp)
    }
    
    public static func build(recipient: Address, sender: Address, lockIntervalSinceNow: TimeInterval, secret: Data, hashOp: HashOperator) -> Script? {
        let hash = hashOp.hash(secret)
        let lockDate = Date(timeIntervalSinceNow: lockIntervalSinceNow)
        return build(recipient: recipient, sender: sender, lockDate: lockDate, hash: hash, hashOp: hashOp)
    }
    
    public static func build(recipient: Address, sender: Address, lockDate: Date, secret: Data, hashOp: HashOperator) -> Script? {
        let hash = hashOp.hash(secret)
        return build(recipient: recipient, sender: sender, lockDate: lockDate, hash: hash, hashOp: hashOp)
    }

}

public enum HashOperator {
    case SHA256, HASH160
    var opcode: OpCode {
        switch self {
        case .SHA256:
            return .OP_SHA256
        case .HASH160:
            return .OP_HASH160
        }
    }
    
    var hashSize: Int {
        switch self {
        case .SHA256:
            return 32
        case .HASH160:
            return 20
        }
    }
    
    func hash(_ data: Data) -> Data {
        switch self {
        case .SHA256:
            return Crypto.sha256(data)
        case .HASH160:
            return Crypto.sha256ripemd160(data)
        }
    }
}

// MARK: - Utility Extension
private extension Date {
    var bigNumData: Data {
        let dateUnix: TimeInterval = timeIntervalSince1970
        let bn = BigNumber(Int32(dateUnix).littleEndian)
        return bn.data
    }
}
