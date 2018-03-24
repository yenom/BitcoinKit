//
//  BitcoinKit.Private.swift
//  BitcoinKit
//
//  Created by Yusuke Ito on 03/24/18.
//  Copyright © 2018 Yusuke Ito. All rights reserved.
//

import Foundation
import COpenSSL

public class _Hash {
    public static func sha256(_ data: Data) -> Data {
        var result = [UInt8](repeating: 0, count: Int(SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes { (ptr: UnsafePointer<UInt8>!) in
            SHA256(ptr, data.count, &result)
        }
        return Data(result)
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