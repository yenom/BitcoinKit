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
    
    func testAddress() {
        // LegacyAddress (Mainnet)
        do {
            let privateKey = try! PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
            let publicKey = privateKey.publicKey()
            let address1 = LegacyAddress(publicKey)
            XCTAssertEqual("\(address1)", publicKey.toAddress())
            
            let address2 = try? LegacyAddress("1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
            XCTAssertNotNil(address2)
            XCTAssertEqual(address2!.cashaddr, "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
            XCTAssertEqual(address1, address2)
            
            do {
                _ = try LegacyAddress("175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W")
                XCTFail("Should throw invalid checksum error.")
            } catch AddressError.invalid {
                // Success
            } catch {
                XCTFail("Should throw invalid checksum error.")
            }
        }
        
        // LegacyAddress (Testnet)
        do {
            let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
            let publicKey = privateKey.publicKey()
            
            let address1 = LegacyAddress(publicKey)
            XCTAssertEqual("\(address1)", publicKey.toAddress())
            
            let address2 = try? LegacyAddress("mjNkq5ycsAfY9Vybo9jG8wbkC5mbpo4xgC")
            XCTAssertNotNil(address2)
            XCTAssertEqual(address2!.cashaddr, "bchtest:qq498xkl67h0espwqxttfn8hdt4g3g05wqtqeyg993")
            XCTAssertEqual(address1, address2)
        }
        
        // Cashaddr (Mainnet)
        do {
            let privateKey = try! PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
            let publicKey = privateKey.publicKey()
            let address1 = Cashaddr(publicKey)
            XCTAssertEqual("\(address1)", publicKey.toCashaddr())
            
            let address2 = try? Cashaddr("bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
            XCTAssertNotNil(address2)
            XCTAssertEqual("\(address2!)", "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
            
            // invalid address
            do {
                _ = try Cashaddr("bitcoincash:qzdvr2hn0xrz99fcp6hkjxzk848rjvvhgytv4fket8💦😆")
                XCTFail("Should throw invalid checksum error.")
            } catch AddressError.invalid {
                // Success
            } catch {
                XCTFail("Should throw invalid checksum error.")
            }
            
            // wrong network
            do {
                _ = try Cashaddr("pref:pr6m7j9njldwwzlg9v7v53unlr4jkmx6ey65nvtks5")
                XCTFail("Should throw invalid checksum error.")
            } catch AddressError.wrongNetwork {
                // Success
            } catch {
                XCTFail("Should throw invalid checksum error.")
            }
        }
        
        // Cashaddr (Testnet)
        do {
            let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
            let publicKey = privateKey.publicKey()
            
            let address1 = Cashaddr(publicKey)
            XCTAssertEqual("\(address1)", publicKey.toCashaddr())
            
            let address2 = try? Cashaddr("bchtest:qq498xkl67h0espwqxttfn8hdt4g3g05wqtqeyg993")
            XCTAssertNotNil(address2)
            XCTAssertEqual("\(address2!)", "bchtest:qq498xkl67h0espwqxttfn8hdt4g3g05wqtqeyg993")
        }
        
        // AddressFactory
        do {
            // Cashaddr
            let cashaddr = try? AddressFactory.create("bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
            XCTAssertNotNil(cashaddr)
            XCTAssertEqual("\(cashaddr!)", "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
            
            // LegacyAddress
            let legacyAddress = try? AddressFactory.create("1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
            XCTAssertNotNil(legacyAddress)
            XCTAssertEqual(legacyAddress!.cashaddr, "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
        }
    }
}
