//
//  BitcoinKitPrivateSwift.swift
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
import secp256k1

class _SwiftKey {
	public static func computePublicKey(fromPrivateKey privateKey: Data, compression: Bool) -> Data {
		guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
			return Data()
		}
		defer { secp256k1_context_destroy(ctx) }
		var pubkey = secp256k1_pubkey()
		var seckey: [UInt8] = privateKey.map{ $0 }
		if seckey.count != 32 {
			return Data()
		}
		if secp256k1_ec_pubkey_create(ctx, &pubkey, &seckey) == 0 {
			return Data()
		}
		if compression {
			var serializedPubkey = [UInt8](repeating: 0, count: 33)
			var outputlen = 33
			if secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &outputlen, &pubkey, UInt32(SECP256K1_EC_COMPRESSED)) == 0 {
				return Data()
			}
			if outputlen != 33 {
				return Data()
			}
			return Data(bytes: serializedPubkey)			
		} else {
    		var serializedPubkey = [UInt8](repeating: 0, count: 65)
    		var outputlen = 65 
    		if secp256k1_ec_pubkey_serialize(ctx, &serializedPubkey, &outputlen, &pubkey, UInt32(SECP256K1_EC_UNCOMPRESSED)) == 0 {
    			return Data()
    		}
    		if outputlen != 65 {
    			return Data()
    		}
    		return Data(bytes: serializedPubkey)
		}
	}
}
