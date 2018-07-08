//
//  AddressFactoryTests.swift
//  BitcoinKitTests
//
//  Created by Akifumi Fujita on 2018/07/08.
//  Copyright © 2018年 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import BitcoinKit

class AddressFactoryTests: XCTestCase {
    func testAddressFactory() {
        // Cashaddr
        let cashaddr = try? AddressFactory.create("bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
        XCTAssertNotNil(cashaddr)
        XCTAssertEqual("\(cashaddr!)", "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
        
        // invalid address
        do {
            _ = try AddressFactory.create("bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978💦😆")
            XCTFail("Should throw invalid checksum error.")
        } catch AddressError.invalid {
            // Success
        } catch {
            XCTFail("Should throw invalid checksum error.")
        }
        
        // mismatch scheme and address
        do {
            _ = try AddressFactory.create("bchtest:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
            XCTFail("Should throw invalid checksum error.")
        } catch AddressError.invalid {
            // Success
        } catch {
            XCTFail("Should throw invalid checksum error.")
        }
        
        // wrong network
        do {
            _ = try AddressFactory.create("pref:pr6m7j9njldwwzlg9v7v53unlr4jkmx6ey65nvtks5")
            XCTFail("Should throw wrong network.")
        } catch AddressError.wrongNetwork {
            // Success
        } catch {
            XCTFail("Should throw wrong network.")
        }
        
        // LegacyAddress
        let legacyAddress = try? AddressFactory.create("1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
        XCTAssertNotNil(legacyAddress)
        XCTAssertEqual("\(legacyAddress!)", "1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
        XCTAssertEqual(legacyAddress!.cashaddr, "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
        
        // invalid checksum error
        do {
            _ = try AddressFactory.create("175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W")
            XCTFail("Should throw invalid checksum error.")
        } catch AddressError.invalid {
            // Success
        } catch {
            XCTFail("Should throw invalid checksum error.")
        }
    }
}
