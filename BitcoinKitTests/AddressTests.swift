//
//  AddressTests.swift
//  BitcoinKitTests
//
//  Created by Takaoka on 2018/07/07.
//  Copyright © 2018年 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import BitcoinKit

class AddressTests: XCTestCase {
    
    func testMainnetLegacyAddress() {
        let privateKey = try! PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
        let publicKey = privateKey.publicKey()
        let addressFromPublicKey = LegacyAddress(publicKey)
        XCTAssertEqual("\(addressFromPublicKey)", publicKey.toAddress())
        XCTAssertEqual("\(addressFromPublicKey.cashaddr)", publicKey.toCashaddr())
        
        let addressFromFormattedAddress = try? LegacyAddress("1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
        XCTAssertNotNil(addressFromFormattedAddress)
        XCTAssertEqual("\(addressFromFormattedAddress!)", "1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
        XCTAssertEqual(addressFromFormattedAddress!.cashaddr, "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
        
        // invalid checksum error
        do {
            _ = try LegacyAddress("175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W")
            XCTFail("Should throw invalid checksum error.")
        } catch AddressError.invalid {
            // Success
        } catch {
            XCTFail("Should throw invalid checksum error.")
        }
    }
    
    func testTestnetLegacyAddress() {
        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
        let publicKey = privateKey.publicKey()
        let addressFromPublicKey = LegacyAddress(publicKey)
        XCTAssertEqual("\(addressFromPublicKey)", publicKey.toAddress())
        XCTAssertEqual("\(addressFromPublicKey.cashaddr)", publicKey.toCashaddr())
        
        let addressFromFormattedAddress = try? LegacyAddress("mjNkq5ycsAfY9Vybo9jG8wbkC5mbpo4xgC")
        XCTAssertNotNil(addressFromFormattedAddress)
        XCTAssertEqual("\(addressFromFormattedAddress!)", "mjNkq5ycsAfY9Vybo9jG8wbkC5mbpo4xgC")
        XCTAssertEqual(addressFromFormattedAddress!.cashaddr, "bchtest:qq498xkl67h0espwqxttfn8hdt4g3g05wqtqeyg993")
    }
    
    func testMainnetCashaddr() {
        let privateKey = try! PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
        let publicKey = privateKey.publicKey()
        let addressFromPublicKey = Cashaddr(publicKey)
        XCTAssertEqual("\(addressFromPublicKey)", publicKey.toCashaddr())
        
        let addressFromFormattedAddress = try? Cashaddr("bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
        XCTAssertNotNil(addressFromFormattedAddress)
        XCTAssertEqual("\(addressFromFormattedAddress!)", "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
        
        // invalid address
        do {
            _ = try Cashaddr("bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978💦😆")
            XCTFail("Should throw invalid checksum error.")
        } catch AddressError.invalid {
            // Success
        } catch {
            XCTFail("Should throw invalid checksum error.")
        }
        
        // mismatch scheme and address
        do {
            _ = try Cashaddr("bchtest:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
            XCTFail("Should throw invalid checksum error.")
        } catch AddressError.invalid {
            // Success
        } catch {
            XCTFail("Should throw invalid checksum error.")
        }
        
        // wrong network
        do {
            _ = try Cashaddr("pref:pr6m7j9njldwwzlg9v7v53unlr4jkmx6ey65nvtks5")
            XCTFail("Should throw wrong network.")
        } catch AddressError.wrongNetwork {
            // Success
        } catch {
            XCTFail("Should throw wrong network.")
        }
    }
    
    func testTestnetCashaddr() {
        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
        let publicKey = privateKey.publicKey()
        let addressFromPublicKey = Cashaddr(publicKey)
        XCTAssertEqual("\(addressFromPublicKey)", publicKey.toCashaddr())
        
        let addressFromFormattedAddress = try? Cashaddr("bchtest:qq498xkl67h0espwqxttfn8hdt4g3g05wqtqeyg993")
        XCTAssertNotNil(addressFromFormattedAddress)
        XCTAssertEqual("\(addressFromFormattedAddress!)", "bchtest:qq498xkl67h0espwqxttfn8hdt4g3g05wqtqeyg993")
    }
}
