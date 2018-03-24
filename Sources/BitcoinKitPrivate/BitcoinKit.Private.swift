//
//  BitcoinKit.Private.swift
//  BitcoinKit
//
//  Created by Yusuke Ito on 03/24/18.
//  Copyright © 2018 Yusuke Ito. All rights reserved.
//

import Foundation

public class _Hash {
    public static func sha256(_ data: Data) -> Data {
        fatalError("unimplemented")
    }
    public static func ripemd160(_ data: Data) -> Data {
        fatalError("unimplemented")
    }
    public static func hmacsha512(_ data: Data, key: Data) -> Data {
        fatalError("unimplemented")
    }
}

public class _Key {
    public static func computePublicKey(fromPrivateKey privateKey: Data, compression: Bool) -> Data {
        fatalError("unimplemented")
    }
    public static func deriveKey(_ password: Data, salt: Data, iterations:NSInteger, keyLength: NSInteger) -> Data {
        fatalError("unimplemented")
    }
}

public class _HDKey {
    public let publicKey: Data?
    public let privateKey: Data?
    public let chainCode: Data
    public let depth: UInt8
    public let fingerprint: UInt32
    public let childIndex: UInt32
    
    public init(privateKey: Data?, publicKey: Data?, chainCode: Data, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        fatalError("unimplemented")
    }
    public func derived(at: UInt32, hardened: Bool) -> _HDKey? {
        fatalError("unimplemented")
    }
}

// TODO
// it is dummy implementation

public typealias secp256k1_ecdsa_signature = UInt8

public let SECP256K1_CONTEXT_SIGN: Int = {
    fatalError("unimplemented")
}()

public func secp256k1_context_create(_ a: UInt32) -> Int? {
    fatalError("unimplemented")
}

public func secp256k1_ecdsa_sign(_ ctx: Int, _ a: UnsafeMutablePointer<secp256k1_ecdsa_signature>, _ b: UnsafePointer<UInt8>, _ c: UnsafePointer<UInt8>, _ d: Int?, _ e: Int?) -> Int {
    fatalError("unimplemented")
}

public func secp256k1_ecdsa_signature_normalize(_ ctx: Int, _ a: UnsafeMutablePointer<secp256k1_ecdsa_signature>, _ b: UnsafeMutablePointer<secp256k1_ecdsa_signature>) {
    fatalError("unimplemented")
}

public func secp256k1_ecdsa_signature_serialize_der(_ ctx: Int, _ a: UnsafeMutablePointer<UInt8>, _ b: inout size_t, _ c: UnsafeMutablePointer<secp256k1_ecdsa_signature>) -> Int {
    fatalError("unimplemented")
}

public func secp256k1_context_destroy(_ ctx: Int) {
    fatalError("unimplemented")
}