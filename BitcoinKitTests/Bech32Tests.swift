//
//  Bech32Tests.swift
//  BitcoinKitTests
//
//  Created by Takaoka on 2018/07/07.
//  Copyright © 2018年 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import BitcoinKit

class Bech32Tetst: XCTestCase {
    
    func testAll() {
        // invalid strings
        // empty string
        XCTAssertNil(Bech32.decode(""))
        XCTAssertNil(Bech32.decode(" "))
        // invalid upper and lower case at the same time "Q" "zdvr2hn0xrz99fcp6hkjxzk848rjvvhgytv4fket8"
        XCTAssertNil(Bech32.decode("bitcoincash:Qzdvr2hn0xrz99fcp6hkjxzk848rjvvhgytv4fket8"))
        // no prefix
        XCTAssertNil(Bech32.decode("qr6m7j9njldwwzlg9v7v53unlr4jkmx6eylep8ekg2"))
        // invalid prefix "bitcoincash012345"
        XCTAssertNil(Bech32.decode("bitcoincash012345:qzdvr2hn0xrz99fcp6hkjxzk848rjvvhgytv4fket8"))
        // invalid character "1"
        XCTAssertNil(Bech32.decode("bitcoincash:111112hn0xrz99fcp6hkjxzk848rjvvhgytv411111"))
        // unexpected character "💦😆"
        XCTAssertNil(Bech32.decode("bitcoincash:qzdvr2hn0xrz99fcp6hkjxzk848rjvvhgytv4fket8💦😆"))
        // invalid checksum
        XCTAssertNil(Bech32.decode("bitcoincash:zzzzz2hn0xrz99fcp6hkjxzk848rjvvhgytv4zzzzz"))
        
        
        // The following test cases are from the spec about cashaddr
        // https://github.com/bitcoincashorg/bitcoincash.org/blob/master/spec/cashaddr.md
        
        HexEncodesToBech32(hex: "F5BF48B397DAE70BE82B3CCA4793F8EB2B6CDAC9", prefix: "bitcoincash", bech32: "bitcoincash:qr6m7j9njldwwzlg9v7v53unlr4jkmx6eylep8ekg2")
        HexEncodesToBech32(hex: "F5BF48B397DAE70BE82B3CCA4793F8EB2B6CDAC9", prefix: "bchtest", bech32: "bchtest:pr6m7j9njldwwzlg9v7v53unlr4jkmx6eyvwc0uz5t")
        HexEncodesToBech32(hex: "F5BF48B397DAE70BE82B3CCA4793F8EB2B6CDAC9", prefix: "pref", bech32: "pref:pr6m7j9njldwwzlg9v7v53unlr4jkmx6ey65nvtks5")
        HexEncodesToBech32(hex: "F5BF48B397DAE70BE82B3CCA4793F8EB2B6CDAC9", prefix: "prefix", bech32: "prefix:0r6m7j9njldwwzlg9v7v53unlr4jkmx6ey3qnjwsrf")
        
        HexEncodesToBech32(hex: "7ADBF6C17084BC86C1706827B41A56F5CA32865925E946EA", prefix: "bitcoincash", bech32: "bitcoincash:q9adhakpwzztepkpwp5z0dq62m6u5v5xtyj7j3h2ws4mr9g0")
        HexEncodesToBech32(hex: "7ADBF6C17084BC86C1706827B41A56F5CA32865925E946EA", prefix: "bchtest", bech32: "bchtest:p9adhakpwzztepkpwp5z0dq62m6u5v5xtyj7j3h2u94tsynr")
        HexEncodesToBech32(hex: "7ADBF6C17084BC86C1706827B41A56F5CA32865925E946EA", prefix: "pref", bech32: "pref:p9adhakpwzztepkpwp5z0dq62m6u5v5xtyj7j3h2khlwwk5v")
        HexEncodesToBech32(hex: "7ADBF6C17084BC86C1706827B41A56F5CA32865925E946EA", prefix: "prefix", bech32: "prefix:09adhakpwzztepkpwp5z0dq62m6u5v5xtyj7j3h2p29kc2lp")
        
        HexEncodesToBech32(hex: "D0F346310D5513D9E01E299978624BA883E6BDA8F4C60883C10F28C2967E67EC77ECC7EEEAEAFC6DA89FAD72D11AC961E164678B868AEEEC5F2C1DA08884175B", prefix: "bitcoincash", bech32: "bitcoincash:qlg0x333p4238k0qrc5ej7rzfw5g8e4a4r6vvzyrcy8j3s5k0en7calvclhw46hudk5flttj6ydvjc0pv3nchp52amk97tqa5zygg96mtky5sv5w")
        HexEncodesToBech32(hex: "D0F346310D5513D9E01E299978624BA883E6BDA8F4C60883C10F28C2967E67EC77ECC7EEEAEAFC6DA89FAD72D11AC961E164678B868AEEEC5F2C1DA08884175B", prefix: "bchtest", bech32: "bchtest:plg0x333p4238k0qrc5ej7rzfw5g8e4a4r6vvzyrcy8j3s5k0en7calvclhw46hudk5flttj6ydvjc0pv3nchp52amk97tqa5zygg96mc773cwez")
        HexEncodesToBech32(hex: "D0F346310D5513D9E01E299978624BA883E6BDA8F4C60883C10F28C2967E67EC77ECC7EEEAEAFC6DA89FAD72D11AC961E164678B868AEEEC5F2C1DA08884175B", prefix: "pref", bech32: "pref:plg0x333p4238k0qrc5ej7rzfw5g8e4a4r6vvzyrcy8j3s5k0en7calvclhw46hudk5flttj6ydvjc0pv3nchp52amk97tqa5zygg96mg7pj3lh8")
        HexEncodesToBech32(hex: "D0F346310D5513D9E01E299978624BA883E6BDA8F4C60883C10F28C2967E67EC77ECC7EEEAEAFC6DA89FAD72D11AC961E164678B868AEEEC5F2C1DA08884175B", prefix: "prefix", bech32: "prefix:0lg0x333p4238k0qrc5ej7rzfw5g8e4a4r6vvzyrcy8j3s5k0en7calvclhw46hudk5flttj6ydvjc0pv3nchp52amk97tqa5zygg96ms92w6845")

    }
    
    func HexEncodesToBech32(hex: String, prefix: String, bech32: String) {
        //Encode
        let data = Data(hex: hex)!
        XCTAssertEqual(Bech32.encode(Data([AddressType.pubkeyHash.versionByte160]) + data, prefix: prefix), bech32)
        //Decode
        XCTAssertEqual(Bech32.decode(bech32)!.prefix, prefix)
        XCTAssertEqual(Bech32.decode(bech32)!.data.dropFirst().hex, hex)
    }
}
