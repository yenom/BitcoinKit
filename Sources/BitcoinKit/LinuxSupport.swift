//
//  LinuxSupport.swift
//  BitcoinKit
//
//  Created by Yusuke Ito on 3/25/18.
//
import Foundation
import Random

// Linux missing implementaion
#if !os(macOS) && !os(iOS) && !os(tvOS) && !os(watchOS)
let errSecSuccess: Int32 = 0
let kSecRandomDefault = 0

var randomGlobal: RandomProtocol?

func SecRandomCopyBytes(_ a: Int, _ count: Int, _ ptr: UnsafeMutableRawPointer) -> Int32 {
    if randomGlobal == nil {
        randomGlobal = try? URandom()
    }
    guard let random = randomGlobal else {
        print("could not create URandom")
        return -1
    }
    guard let bytes = try? random.bytes(count: count) else {
        print("could not generate random")
        return -1
    }
    _ = bytes.withUnsafeBytes {
        memcpy(ptr, $0.baseAddress!, count)
    }
    return errSecSuccess
}
#endif
