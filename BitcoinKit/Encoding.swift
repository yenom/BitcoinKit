//
//  Encoding.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/30.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

fileprivate protocol Encoding {
    static var baseAlphabets: String { get }
    static var zeroAlphabet: Character { get }
    static var base: Int { get }
    
    // log(256) / log(base), rounded up
    static func sizeFromByte(size: Int) -> Int
    // log(base) / log(256), rounded up
    static func sizeFromBase(size: Int) -> Int
    
    // Public
    static func encode(_ bytes: Data) -> String
    static func decode(_ string: String) -> Data
}

fileprivate struct _Base32: Encoding {
    static let baseAlphabets = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"
    static var zeroAlphabet: Character = "q"
    static var base: Int = 32
    
    static func sizeFromByte(size: Int) -> Int {
        // log(256) / log(32), rounded up
        return size * 8 / 5 + 1
    }
    static func sizeFromBase(size: Int) -> Int {
        // log(32) / log(256), rounded up.
        return size * 5 / 8 + 1
    }
}

// The Base58 encoding used is home made, and has some differences. Especially,
// leading zeros are kept as single zeroes when conversion happens.
fileprivate struct _Base58: Encoding {
    static let baseAlphabets = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    static var zeroAlphabet: Character = "1"
    static var base: Int = 58
    
    static func sizeFromByte(size: Int) -> Int {
        // log(256) / log(58), rounded up
        return size * 138 / 100 + 1
    }
    static func sizeFromBase(size: Int) -> Int {
        // log(58) / log(256), rounded up.
        return size * 733 / 1000 + 1
    }
}

public struct Base32 {
    public static func encode(_ bytes: Data) -> String {
        return _Base32.encode(bytes)
    }
    public static func decode(_ string: String) -> Data {
        return _Base32.decode(string)
    }
}

public struct Base58 {
    public static func encode(_ bytes: Data) -> String {
        return _Base58.encode(bytes)
    }
    public static func decode(_ string: String) -> Data {
        return _Base58.decode(string)
    }
}

extension Encoding {
    static func encode(_ bytes: Data) -> String {
        var bytes = bytes
        var zerosCount = 0
        var length = 0
        
        for b in bytes {
            if b != 0 { break }
            zerosCount += 1
        }
        
        bytes.removeFirst(zerosCount)

        let size = sizeFromByte(size: bytes.count)
        var encodedBytes: [UInt8] = Array(repeating: 0, count: size)
        for b in bytes {
            var carry = Int(b)
            var i = 0
            for j in (0...encodedBytes.count-1).reversed() where carry != 0 || i < length {
                carry += 256 * Int(encodedBytes[j])
                encodedBytes[j] = UInt8(carry % base)
                carry /= base
                i += 1
            }
            
            assert(carry == 0)
            
            length = i
        }
        
        var zerosToRemove = 0
        var str = ""
        for b in encodedBytes {
            if b != 0 { break }
            zerosToRemove += 1
        }
        
        encodedBytes.removeFirst(zerosToRemove)
        while 0 < zerosCount {
            str += String(zeroAlphabet)
            zerosCount -= 1
        }
        
        for b in encodedBytes {
            str += String(baseAlphabets[String.Index(encodedOffset: Int(b))])
        }
        
        return str
    }
    
    static func decode(_ string: String) -> Data {
        // remove leading and trailing whitespaces
        let string = string.trimmingCharacters(in: .whitespaces)
        
        guard !string.isEmpty else { return Data() }
        
        var zerosCount = 0
        var length = 0
        for c in string {
            if c != zeroAlphabet { break }
            zerosCount += 1
        }
        let size = sizeFromBase(size: string.lengthOfBytes(using: .utf8) - zerosCount)
        var decodedBytes: [UInt8] = Array(repeating: 0, count: size)
        // TODO: whitespaceは既に除去してるので、このwhere条件はいらないことが確認できたら削除
        for c in string where c != " " {
            guard let baseIndex = baseAlphabets.index(of: c) else { return Data() }
            
            var carry = baseIndex.encodedOffset
            var i = 0
            for j in (0...decodedBytes.count - 1).reversed() where carry != 0 || i < length {
                carry += base * Int(decodedBytes[j])
                decodedBytes[j] = UInt8(carry % 256)
                carry /= 256
                i += 1
            }
            
            assert(carry == 0)
            length = i
        }
        
        // skip leading zeros
        var zerosToRemove = 0
        
        for b in decodedBytes {
            if b != 0 { break }
            zerosToRemove += 1
        }
        decodedBytes.removeFirst(zerosToRemove)
        
        return Data(repeating: 0, count: zerosCount) + Data(decodedBytes)
    }
}

