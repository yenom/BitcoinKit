//
//  Bech32Tests.swift
//
//  Copyright © 2018 BitcoinKit developers
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
        
        HexEncodesToBech32(hex: "F5BF48B397DAE70BE82B3CCA4793F8EB2B6CDAC9", prefix: "bitcoincash", bech32: "bitcoincash:qr6m7j9njldwwzlg9v7v53unlr4jkmx6eylep8ekg2", versionByte: 0)
        HexEncodesToBech32(hex: "F5BF48B397DAE70BE82B3CCA4793F8EB2B6CDAC9", prefix: "bchtest", bech32: "bchtest:pr6m7j9njldwwzlg9v7v53unlr4jkmx6eyvwc0uz5t", versionByte: 8)
        HexEncodesToBech32(hex: "F5BF48B397DAE70BE82B3CCA4793F8EB2B6CDAC9", prefix: "pref", bech32: "pref:pr6m7j9njldwwzlg9v7v53unlr4jkmx6ey65nvtks5", versionByte: 8)
        HexEncodesToBech32(hex: "F5BF48B397DAE70BE82B3CCA4793F8EB2B6CDAC9", prefix: "prefix", bech32: "prefix:0r6m7j9njldwwzlg9v7v53unlr4jkmx6ey3qnjwsrf", versionByte: 120)
        
        HexEncodesToBech32(hex: "7ADBF6C17084BC86C1706827B41A56F5CA32865925E946EA", prefix: "bitcoincash", bech32: "bitcoincash:q9adhakpwzztepkpwp5z0dq62m6u5v5xtyj7j3h2ws4mr9g0", versionByte: 1)
        HexEncodesToBech32(hex: "7ADBF6C17084BC86C1706827B41A56F5CA32865925E946EA", prefix: "bchtest", bech32: "bchtest:p9adhakpwzztepkpwp5z0dq62m6u5v5xtyj7j3h2u94tsynr", versionByte: 9)
        HexEncodesToBech32(hex: "7ADBF6C17084BC86C1706827B41A56F5CA32865925E946EA", prefix: "pref", bech32: "pref:p9adhakpwzztepkpwp5z0dq62m6u5v5xtyj7j3h2khlwwk5v", versionByte: 9)
        HexEncodesToBech32(hex: "7ADBF6C17084BC86C1706827B41A56F5CA32865925E946EA", prefix: "prefix", bech32: "prefix:09adhakpwzztepkpwp5z0dq62m6u5v5xtyj7j3h2p29kc2lp", versionByte: 121)
        
        HexEncodesToBech32(hex: "3A84F9CF51AAE98A3BB3A78BF16A6183790B18719126325BFC0C075B", prefix: "bitcoincash", bech32: "bitcoincash:qgagf7w02x4wnz3mkwnchut2vxphjzccwxgjvvjmlsxqwkcw59jxxuz", versionByte: 2)
        HexEncodesToBech32(hex: "3A84F9CF51AAE98A3BB3A78BF16A6183790B18719126325BFC0C075B", prefix: "bchtest", bech32: "bchtest:pgagf7w02x4wnz3mkwnchut2vxphjzccwxgjvvjmlsxqwkcvs7md7wt", versionByte: 10)
        HexEncodesToBech32(hex: "3A84F9CF51AAE98A3BB3A78BF16A6183790B18719126325BFC0C075B", prefix: "pref", bech32: "pref:pgagf7w02x4wnz3mkwnchut2vxphjzccwxgjvvjmlsxqwkcrsr6gzkn", versionByte: 10)
        HexEncodesToBech32(hex: "3A84F9CF51AAE98A3BB3A78BF16A6183790B18719126325BFC0C075B", prefix: "prefix", bech32: "prefix:0gagf7w02x4wnz3mkwnchut2vxphjzccwxgjvvjmlsxqwkc5djw8s9g", versionByte: 122)
        
        HexEncodesToBech32(hex: "3173EF6623C6B48FFD1A3DCC0CC6489B0A07BB47A37F47CFEF4FE69DE825C060", prefix: "bitcoincash", bech32: "bitcoincash:qvch8mmxy0rtfrlarg7ucrxxfzds5pamg73h7370aa87d80gyhqxq5nlegake", versionByte: 3)
        HexEncodesToBech32(hex: "3173EF6623C6B48FFD1A3DCC0CC6489B0A07BB47A37F47CFEF4FE69DE825C060", prefix: "bchtest", bech32: "bchtest:pvch8mmxy0rtfrlarg7ucrxxfzds5pamg73h7370aa87d80gyhqxq7fqng6m6", versionByte: 11)
        HexEncodesToBech32(hex: "3173EF6623C6B48FFD1A3DCC0CC6489B0A07BB47A37F47CFEF4FE69DE825C060", prefix: "pref", bech32: "pref:pvch8mmxy0rtfrlarg7ucrxxfzds5pamg73h7370aa87d80gyhqxq4k9m7qf9", versionByte: 11)
        HexEncodesToBech32(hex: "3173EF6623C6B48FFD1A3DCC0CC6489B0A07BB47A37F47CFEF4FE69DE825C060", prefix: "prefix", bech32: "prefix:0vch8mmxy0rtfrlarg7ucrxxfzds5pamg73h7370aa87d80gyhqxqsh6jgp6w", versionByte: 123)
        
        HexEncodesToBech32(hex: "C07138323E00FA4FC122D3B85B9628EA810B3F381706385E289B0B25631197D194B5C238BEB136FB", prefix: "bitcoincash", bech32: "bitcoincash:qnq8zwpj8cq05n7pytfmskuk9r4gzzel8qtsvwz79zdskftrzxtar994cgutavfklv39gr3uvz", versionByte: 4)
        HexEncodesToBech32(hex: "C07138323E00FA4FC122D3B85B9628EA810B3F381706385E289B0B25631197D194B5C238BEB136FB", prefix: "bchtest", bech32: "bchtest:pnq8zwpj8cq05n7pytfmskuk9r4gzzel8qtsvwz79zdskftrzxtar994cgutavfklvmgm6ynej", versionByte: 12)
        HexEncodesToBech32(hex: "C07138323E00FA4FC122D3B85B9628EA810B3F381706385E289B0B25631197D194B5C238BEB136FB", prefix: "pref", bech32: "pref:pnq8zwpj8cq05n7pytfmskuk9r4gzzel8qtsvwz79zdskftrzxtar994cgutavfklv0vx5z0w3", versionByte: 12)
        HexEncodesToBech32(hex: "C07138323E00FA4FC122D3B85B9628EA810B3F381706385E289B0B25631197D194B5C238BEB136FB", prefix: "prefix", bech32: "prefix:0nq8zwpj8cq05n7pytfmskuk9r4gzzel8qtsvwz79zdskftrzxtar994cgutavfklvwsvctzqy", versionByte: 124)
        
        HexEncodesToBech32(hex: "E361CA9A7F99107C17A622E047E3745D3E19CF804ED63C5C40C6BA763696B98241223D8CE62AD48D863F4CB18C930E4C", prefix: "bitcoincash", bech32: "bitcoincash:qh3krj5607v3qlqh5c3wq3lrw3wnuxw0sp8dv0zugrrt5a3kj6ucysfz8kxwv2k53krr7n933jfsunqex2w82sl", versionByte: 5)
        HexEncodesToBech32(hex: "E361CA9A7F99107C17A622E047E3745D3E19CF804ED63C5C40C6BA763696B98241223D8CE62AD48D863F4CB18C930E4C", prefix: "bchtest", bech32: "bchtest:ph3krj5607v3qlqh5c3wq3lrw3wnuxw0sp8dv0zugrrt5a3kj6ucysfz8kxwv2k53krr7n933jfsunqnzf7mt6x", versionByte: 13)
        HexEncodesToBech32(hex: "E361CA9A7F99107C17A622E047E3745D3E19CF804ED63C5C40C6BA763696B98241223D8CE62AD48D863F4CB18C930E4C", prefix: "pref", bech32: "pref:ph3krj5607v3qlqh5c3wq3lrw3wnuxw0sp8dv0zugrrt5a3kj6ucysfz8kxwv2k53krr7n933jfsunqjntdfcwg", versionByte: 13)
        HexEncodesToBech32(hex: "E361CA9A7F99107C17A622E047E3745D3E19CF804ED63C5C40C6BA763696B98241223D8CE62AD48D863F4CB18C930E4C", prefix: "prefix", bech32: "prefix:0h3krj5607v3qlqh5c3wq3lrw3wnuxw0sp8dv0zugrrt5a3kj6ucysfz8kxwv2k53krr7n933jfsunqakcssnmn", versionByte: 125)
        
        HexEncodesToBech32(hex: "D9FA7C4C6EF56DC4FF423BAAE6D495DBFF663D034A72D1DC7D52CBFE7D1E6858F9D523AC0A7A5C34077638E4DD1A701BD017842789982041", prefix: "bitcoincash", bech32: "bitcoincash:qmvl5lzvdm6km38lgga64ek5jhdl7e3aqd9895wu04fvhlnare5937w4ywkq57juxsrhvw8ym5d8qx7sz7zz0zvcypqscw8jd03f", versionByte: 6)
        HexEncodesToBech32(hex: "D9FA7C4C6EF56DC4FF423BAAE6D495DBFF663D034A72D1DC7D52CBFE7D1E6858F9D523AC0A7A5C34077638E4DD1A701BD017842789982041", prefix: "bchtest", bech32: "bchtest:pmvl5lzvdm6km38lgga64ek5jhdl7e3aqd9895wu04fvhlnare5937w4ywkq57juxsrhvw8ym5d8qx7sz7zz0zvcypqs6kgdsg2g", versionByte: 14)
        HexEncodesToBech32(hex: "D9FA7C4C6EF56DC4FF423BAAE6D495DBFF663D034A72D1DC7D52CBFE7D1E6858F9D523AC0A7A5C34077638E4DD1A701BD017842789982041", prefix: "pref", bech32: "pref:pmvl5lzvdm6km38lgga64ek5jhdl7e3aqd9895wu04fvhlnare5937w4ywkq57juxsrhvw8ym5d8qx7sz7zz0zvcypqsammyqffl", versionByte: 14)
        HexEncodesToBech32(hex: "D9FA7C4C6EF56DC4FF423BAAE6D495DBFF663D034A72D1DC7D52CBFE7D1E6858F9D523AC0A7A5C34077638E4DD1A701BD017842789982041", prefix: "prefix", bech32: "prefix:0mvl5lzvdm6km38lgga64ek5jhdl7e3aqd9895wu04fvhlnare5937w4ywkq57juxsrhvw8ym5d8qx7sz7zz0zvcypqsgjrqpnw8", versionByte: 126)
        
        
        HexEncodesToBech32(hex: "D0F346310D5513D9E01E299978624BA883E6BDA8F4C60883C10F28C2967E67EC77ECC7EEEAEAFC6DA89FAD72D11AC961E164678B868AEEEC5F2C1DA08884175B", prefix: "bitcoincash", bech32: "bitcoincash:qlg0x333p4238k0qrc5ej7rzfw5g8e4a4r6vvzyrcy8j3s5k0en7calvclhw46hudk5flttj6ydvjc0pv3nchp52amk97tqa5zygg96mtky5sv5w", versionByte: 7)
        HexEncodesToBech32(hex: "D0F346310D5513D9E01E299978624BA883E6BDA8F4C60883C10F28C2967E67EC77ECC7EEEAEAFC6DA89FAD72D11AC961E164678B868AEEEC5F2C1DA08884175B", prefix: "bchtest", bech32: "bchtest:plg0x333p4238k0qrc5ej7rzfw5g8e4a4r6vvzyrcy8j3s5k0en7calvclhw46hudk5flttj6ydvjc0pv3nchp52amk97tqa5zygg96mc773cwez", versionByte: 15)
        HexEncodesToBech32(hex: "D0F346310D5513D9E01E299978624BA883E6BDA8F4C60883C10F28C2967E67EC77ECC7EEEAEAFC6DA89FAD72D11AC961E164678B868AEEEC5F2C1DA08884175B", prefix: "pref", bech32: "pref:plg0x333p4238k0qrc5ej7rzfw5g8e4a4r6vvzyrcy8j3s5k0en7calvclhw46hudk5flttj6ydvjc0pv3nchp52amk97tqa5zygg96mg7pj3lh8", versionByte: 15)
        HexEncodesToBech32(hex: "D0F346310D5513D9E01E299978624BA883E6BDA8F4C60883C10F28C2967E67EC77ECC7EEEAEAFC6DA89FAD72D11AC961E164678B868AEEEC5F2C1DA08884175B", prefix: "prefix", bech32: "prefix:0lg0x333p4238k0qrc5ej7rzfw5g8e4a4r6vvzyrcy8j3s5k0en7calvclhw46hudk5flttj6ydvjc0pv3nchp52amk97tqa5zygg96ms92w6845", versionByte: 127)

    }
    
    func HexEncodesToBech32(hex: String, prefix: String, bech32: String, versionByte: UInt8) {
        //Encode
        let data = Data(hex: hex)!
        XCTAssertEqual(Bech32.encode(Data([versionByte]) + data, prefix: prefix), bech32)
        //Decode
        let data2 = Bech32.decode(bech32)!
        XCTAssertEqual(data2.prefix, prefix)
        XCTAssertEqual(data2.data.dropFirst().hex, hex.lowercased())
        XCTAssertEqual(data2.data[0], versionByte)
    }
}
