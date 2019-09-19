//
//  MurmurHashTests.swift
//
//  Copyright © 2018 Kishikawa Katsumi
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

class MurmurHashTests: XCTestCase {
    func testMurmurHash() {
        let testdata = """
            a|0|1009084850
            a|123|614733482
            a|123456|72886628
            aa|0|923832745
            aa|123|1123247799
            aa|123456|39475467
            aaa|0|3033554871
            aaa|123|119196519
            aaa|123456|3748893438
            aaaa|0|2129582471
            aaaa|123|2793246965
            aaaa|123456|489346618
            aaaaa|0|3922341931
            aaaaa|123|1867855708
            aaaaa|123456|3305640622
            aaaaaa|0|1736445713
            aaaaaa|123|3761967641
            aaaaaa|123456|1716679541
            aaaaaaa|0|1497565372
            aaaaaaa|123|2236960971
            aaaaaaa|123456|3622370116
            aaaaaaaa|0|3662943087
            aaaaaaaa|123|3489379964
            aaaaaaaa|123456|3318958783
            aaaaaaaaa|0|2724714153
            aaaaaaaaa|123|1738171864
            aaaaaaaaa|123456|3477381017
            aaaaaaaaaa|0|3246374134
            aaaaaaaaaa|123|2112354061
            aaaaaaaaaa|123456|3952605240
            aaaaaaaaaaa|0|2202513849
            aaaaaaaaaaa|123|2960369010
            aaaaaaaaaaa|123456|2619023100
            aaaaaaaaaaaa|0|1277806314
            aaaaaaaaaaaa|123|3265656582
            aaaaaaaaaaaa|123456|227448751
            aaaaaaaaaaaaa|0|1382425508
            aaaaaaaaaaaaa|123|590782350
            aaaaaaaaaaaaa|123456|1708234424
            aaaaaaaaaaaaaa|0|3803928550
            aaaaaaaaaaaaaa|123|3426615493
            aaaaaaaaaaaaaa|123456|1000613333
            aaaaaaaaaaaaaaa|0|3060510823
            aaaaaaaaaaaaaaa|123|982665824
            aaaaaaaaaaaaaaa|123456|361619402
            aaaaaaaaaaaaaaaa|0|4187236331
            aaaaaaaaaaaaaaaa|123|813829637
            aaaaaaaaaaaaaaaa|123456|3667352872
            aaaaaaaaaaaaaaaaa|0|2130955277
            aaaaaaaaaaaaaaaaa|123|594106781
            aaaaaaaaaaaaaaaaa|123456|1342033804
            aaaaaaaaaaaaaaaaaa|0|3439707509
            aaaaaaaaaaaaaaaaaa|123|3928844096
            aaaaaaaaaaaaaaaaaa|123456|1005235302
            aaaaaaaaaaaaaaaaaaa|0|2021559293
            aaaaaaaaaaaaaaaaaaa|123|73603905
            aaaaaaaaaaaaaaaaaaa|123456|1726036433
            aaaaaaaaaaaaaaaaaaaa|0|3456348433
            aaaaaaaaaaaaaaaaaaaa|123|4065265212
            aaaaaaaaaaaaaaaaaaaa|123456|3069584396
            aaaaaaaaaaaaaaaaaaaaa|0|1731758933
            aaaaaaaaaaaaaaaaaaaaa|123|9580998
            aaaaaaaaaaaaaaaaaaaaa|123456|1241810772
            aaaaaaaaaaaaaaaaaaaaaa|0|139120531
            aaaaaaaaaaaaaaaaaaaaaa|123|1226208072
            aaaaaaaaaaaaaaaaaaaaaa|123456|2968665761
            aaaaaaaaaaaaaaaaaaaaaaa|0|3942082027
            aaaaaaaaaaaaaaaaaaaaaaa|123|4206263016
            aaaaaaaaaaaaaaaaaaaaaaa|123456|398674973
            aaaaaaaaaaaaaaaaaaaaaaaa|0|148242264
            aaaaaaaaaaaaaaaaaaaaaaaa|123|2860956219
            aaaaaaaaaaaaaaaaaaaaaaaa|123456|2365246869
            aaaaaaaaaaaaaaaaaaaaaaaaa|0|101435588
            aaaaaaaaaaaaaaaaaaaaaaaaa|123|1772998873
            aaaaaaaaaaaaaaaaaaaaaaaaa|123456|1511156389
            aaaaaaaaaaaaaaaaaaaaaaaaaa|0|518896862
            aaaaaaaaaaaaaaaaaaaaaaaaaa|123|1440640404
            aaaaaaaaaaaaaaaaaaaaaaaaaa|123456|2902421043
            aaaaaaaaaaaaaaaaaaaaaaaaaaa|0|3770323023
            aaaaaaaaaaaaaaaaaaaaaaaaaaa|123|3666781087
            aaaaaaaaaaaaaaaaaaaaaaaaaaa|123456|2314638503
            aaaaaaaaaaaaaaaaaaaaaaaaaaaa|0|1141098993
            aaaaaaaaaaaaaaaaaaaaaaaaaaaa|123|4047389580
            aaaaaaaaaaaaaaaaaaaaaaaaaaaa|123456|1805461563
            aaaaaaaaaaaaaaaaaaaaaaaaaaaaa|0|2090152050
            aaaaaaaaaaaaaaaaaaaaaaaaaaaaa|123|1103358173
            aaaaaaaaaaaaaaaaaaaaaaaaaaaaa|123456|1971267596
            aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa|0|3925021994
            aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa|123|2075760499
            aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa|123456|1623854675
            aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa|0|1840309804
            aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa|123|1662598756
            aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa|123456|3492266162
            aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa|0|3177955424
            aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa|123|2814155776
            aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa|123456|2621735375
            """
        for line in testdata.split(separator: "\n") {
            let items = line.split(separator: "|")
            let data = items[0]
            let seed = UInt32(items[1])!
            let expect = UInt32(items[2])!
            XCTAssertEqual(MurmurHash.hashValue(data.data(using: .ascii)!, seed), expect)
        }
    }
}
