//
//  LinuxMain.swift
//  BitcoinKit
//
//  Created by Yusuke Ito on 3/24/18.
//

import XCTest
@testable import BitcoinKitTests

// swift test -l | sed 's/\([A-Za-z]*\)\.\([A-Za-z]*\)\/\(.*\)/ testCase([("\1.\2.\3", \2.\3)]),/'
XCTMain([
    testCase([("BitcoinKitTests.BitcoinKitTests.testAddress", BitcoinKitTests.testAddress)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testBase58_1", BitcoinKitTests.testBase58_1)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testBase58_2", BitcoinKitTests.testBase58_2)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testBloomFilter", BitcoinKitTests.testBloomFilter)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testConvertIP", BitcoinKitTests.testConvertIP)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testGenerateKeyPair", BitcoinKitTests.testGenerateKeyPair)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testHDKey1", BitcoinKitTests.testHDKey1)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testHDKey2", BitcoinKitTests.testHDKey2)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testHDKey3", BitcoinKitTests.testHDKey3)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testHDKey4", BitcoinKitTests.testHDKey4)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testHDKeychain", BitcoinKitTests.testHDKeychain)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testMnemonic1", BitcoinKitTests.testMnemonic1)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testMnemonic2", BitcoinKitTests.testMnemonic2)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testMurmurHash", BitcoinKitTests.testMurmurHash)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testPaymentURI", BitcoinKitTests.testPaymentURI)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testScript", BitcoinKitTests.testScript)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testSHA256", BitcoinKitTests.testSHA256)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testSHA256RIPEMD160", BitcoinKitTests.testSHA256RIPEMD160)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testSign", BitcoinKitTests.testSign)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testSignTransaction1", BitcoinKitTests.testSignTransaction1)]),
    testCase([("BitcoinKitTests.BitcoinKitTests.testWIF", BitcoinKitTests.testWIF)]),
])
