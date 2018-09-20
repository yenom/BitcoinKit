//
//  Crypto.swift
//
//  Copyright © 2018 Kishikawa Katsumi
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
#if BitcoinKitXcode
import BitcoinKit.Private
#else
import BitcoinKitPrivate
#endif

public struct Crypto {
    public static func sha1(_ data: Data) -> Data {
        return _Hash.sha1(data)
    }

    public static func sha256(_ data: Data) -> Data {
        return _Hash.sha256(data)
    }

    public static func sha256sha256(_ data: Data) -> Data {
        return sha256(sha256(data))
    }

    public static func ripemd160(_ data: Data) -> Data {
        return _Hash.ripemd160(data)
    }

    public static func sha256ripemd160(_ data: Data) -> Data {
        return ripemd160(sha256(data))
    }

    public static func hmacsha512(data: Data, key: Data) -> Data {
        return _Hash.hmacsha512(data, key: key)
    }

    public static func sign(_ data: Data, privateKey: PrivateKey) throws -> Data {
        #if BitcoinKitXcode
        return _Crypto.signMessage(data, withPrivateKey: privateKey.data)
        #else
        return try _Crypto.signMessage(data, withPrivateKey: privateKey.data)
        #endif
    }

    public static func verifySignature(_ signature: Data, message: Data, publicKey: Data) throws -> Bool {
        #if BitcoinKitXcode
        return _Crypto.verifySignature(signature, message: message, publicKey: publicKey)
        #else
        return try _Crypto.verifySignature(signature, message: message, publicKey: publicKey)
        #endif
    }

    public static func verifySigData(for tx: Transaction, inputIndex: Int, utxo: TransactionOutput, sigData: Data, pubKeyData: Data) throws -> Bool {
        // Hash type is one byte tacked on to the end of the signature. So the signature shouldn't be empty.
        guard !sigData.isEmpty else {
            throw ScriptMachineError.error("SigData is empty.")
        }
        // Extract hash type from the last byte of the signature.
        let hashType = SighashType(sigData.last!)
        // Strip that last byte to have a pure signature.
        let signature = sigData.dropLast()

        let sighash: Data = tx.signatureHash(for: utxo, inputIndex: inputIndex, hashType: hashType)

        return try Crypto.verifySignature(signature, message: sighash, publicKey: pubKeyData)
    }
}

public enum CryptoError: Error {
    case signFailed
    case noEnoughSpace
    case signatureParseFailed
    case publicKeyParseFailed
}
