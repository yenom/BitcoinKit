//
//  AddressTests.swift
//  BitcoinKitTests
//
//  Created by Akifumi Fujita on 2018/07/07.
//  Copyright © 2018 Akifumi Fujita
//  Copyright © 2018 BitcoinCashKit developers
//  Licensed under the Apache License, Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  This file has been modified by the BitcoinCashKit developers for the BitcoinCashKit project.
//  The original file was from the bitcoinj project (https://github.com/kishikawakatsumi/BitcoinKit).
//

import XCTest
@testable import BitcoinKit

class AddressTests: XCTestCase {
    
    func testMainnetLegacyAddress() {
        let privateKey = try! PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
        let publicKey = privateKey.publicKey()
        let addressFromPublicKey = LegacyAddress(publicKey)
        XCTAssertEqual("\(addressFromPublicKey)", "1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
        XCTAssertEqual("\(addressFromPublicKey.cashaddr)", "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
        
        let addressFromFormattedAddress = try? LegacyAddress("1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
        XCTAssertNotNil(addressFromFormattedAddress)
        XCTAssertEqual("\(addressFromFormattedAddress!)", "1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
        XCTAssertEqual(addressFromFormattedAddress!.cashaddr, "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
    }
    
    func testTestnetLegacyAddress() {
        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
        let publicKey = privateKey.publicKey()
        let addressFromPublicKey = LegacyAddress(publicKey)
        XCTAssertEqual("\(addressFromPublicKey)", "mjNkq5ycsAfY9Vybo9jG8wbkC5mbpo4xgC")
        XCTAssertEqual("\(addressFromPublicKey.cashaddr)", "bchtest:qq498xkl67h0espwqxttfn8hdt4g3g05wqtqeyg993")
        
        let addressFromFormattedAddress = try? LegacyAddress("mjNkq5ycsAfY9Vybo9jG8wbkC5mbpo4xgC")
        XCTAssertNotNil(addressFromFormattedAddress)
        XCTAssertEqual("\(addressFromFormattedAddress!)", "mjNkq5ycsAfY9Vybo9jG8wbkC5mbpo4xgC")
        XCTAssertEqual(addressFromFormattedAddress!.cashaddr, "bchtest:qq498xkl67h0espwqxttfn8hdt4g3g05wqtqeyg993")
    }
    
    func testInvalidChecksumLegacyAddress() {
        do {
            _ = try LegacyAddress("175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W")
            XCTFail("Should throw invalid checksum error.")
        } catch AddressError.invalid {
            // Success
        } catch {
            XCTFail("Should throw invalid checksum error.")
        }
    }
    
    func testMainnetCashaddr() {
        let privateKey = try! PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
        let publicKey = privateKey.publicKey()
        let addressFromPublicKey = Cashaddr(publicKey)
        XCTAssertEqual("\(addressFromPublicKey)", "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
        
        let addressFromFormattedAddress = try? Cashaddr("bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
        XCTAssertNotNil(addressFromFormattedAddress)
        XCTAssertEqual("\(addressFromFormattedAddress!)", "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
    }
    
    func testTestnetCashaddr() {
        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
        let publicKey = privateKey.publicKey()
        let addressFromPublicKey = Cashaddr(publicKey)
        XCTAssertEqual("\(addressFromPublicKey)", "bchtest:qq498xkl67h0espwqxttfn8hdt4g3g05wqtqeyg993")
        
        let addressFromFormattedAddress = try? Cashaddr("bchtest:qq498xkl67h0espwqxttfn8hdt4g3g05wqtqeyg993")
        XCTAssertNotNil(addressFromFormattedAddress)
        XCTAssertEqual("\(addressFromFormattedAddress!)", "bchtest:qq498xkl67h0espwqxttfn8hdt4g3g05wqtqeyg993")
    }
    
    func testInvalidChecksumCashaddr() {
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
    }
    
    func testWrongNetworkCashaddr() {
        do {
            _ = try Cashaddr("pref:pr6m7j9njldwwzlg9v7v53unlr4jkmx6ey65nvtks5")
            XCTFail("Should throw wrong network.")
        } catch AddressError.wrongNetwork {
            // Success
        } catch {
            XCTFail("Should throw wrong network.")
        }
    }
}
