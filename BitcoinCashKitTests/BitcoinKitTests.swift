//
//  BitcoinCashKitTests.swift
//
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 BitcoinCashKit developers
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
@testable import BitcoinCashKit

class BitcoinCashKitTests: XCTestCase {
    func testSHA256() {
        /* Usually, when a hash is computed within bitcoin, it is computed twice.
         Most of the time SHA-256 hashes are used, however RIPEMD-160 is also used when a shorter hash is desirable
         (for example when creating a bitcoin address).

         https://en.bitcoin.it/wiki/Protocol_documentation#Hashes
         */
        XCTAssertEqual(Crypto.sha256("hello".data(using: .ascii)!).hex, "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
        XCTAssertEqual(Crypto.sha256sha256("hello".data(using: .ascii)!).hex, "9595c9df90075148eb06860365df33584b75bff782a510c6cd4883a419833d50")
    }

    func testSHA256RIPEMD160() {
        XCTAssertEqual(Crypto.sha256ripemd160("hello".data(using: .ascii)!).hex, "b6a9c8c230722b7c748331a8b450f05566dc7d0f")
    }

    func testGenerateKeyPair() {
        let privateKey = PrivateKey(network: .testnet)
        let publicKey = privateKey.publicKey()

        XCTAssertNotNil(privateKey)
        XCTAssertNotNil(publicKey)

        let wif = privateKey.toWIF()
        let fromWIF = try? PrivateKey(wif: wif)
        XCTAssertEqual(privateKey, fromWIF)
    }

    func testWIF() {
        // Mainnet
        do {
            let privateKey = try? PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
            let publicKey = privateKey?.publicKey()

            XCTAssertNotNil(privateKey)
            XCTAssertNotNil(publicKey)

            XCTAssertEqual(privateKey?.network, Network.mainnet)

            XCTAssertEqual(privateKey?.description, "a7ec27c206a68e33f53d6a35f284c748e0874ca2f0ea56eca6eb7668db0fe805")
            XCTAssertEqual(publicKey?.description, "045d21e7a118c479a007d45401bdbd06e3f9814ad5bbbbc5cec17f19029a060903ccfca71eff2101ad68238112e7585110e0f2c32d345225985356dc7cab8fdcc9")
        }

        // Testnet
        do {
            let privateKey = try? PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
            let publicKey = privateKey?.publicKey()

            XCTAssertNotNil(privateKey)
            XCTAssertNotNil(publicKey)

            XCTAssertEqual(privateKey?.network, Network.testnet)

            XCTAssertEqual(privateKey?.description, "a2359719d3dc9f1539c593e477dc9d57b9653a18e7c94299d87a95ed13525eae")
            XCTAssertEqual(publicKey?.description, "047e000cc16c9a4d38cb1572b9dc34c1452626aa170b46150d0e806be1b42517f0832c8a58f543128083ffb8632bae94dd5f3e1e89fad0a17f64ed8bbbb90b5753")
        }
    }

    func testAddress() {
        // LegacyAddress (Mainnet)
        do {
            let privateKey = try! PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
            let publicKey = privateKey.publicKey()

            let address1 = LegacyAddress(publicKey)
            XCTAssertEqual("\(address1)", publicKey.toAddress())

            let address2 = try? LegacyAddress("1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
            XCTAssertNotNil(address2)
            XCTAssertEqual(address2?.cashaddr, "bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
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
            XCTAssertEqual(address2?.cashaddr, "bchtest:qq498xkl67h0espwqxttfn8hdt4g3g05wqtqeyg993")
            XCTAssertEqual(address1, address2)
        }
        
        // Cashaddr (Mainnet)
        
        // Cashaddr (Testnet)
    }

    func testHDKey1() {
        // Test Vector 1
        /*
         Master (hex): 000102030405060708090a0b0c0d0e0f
         * [Chain m]
         * ext pub: xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8
         * ext prv: xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi
         * [Chain m/0']
         * ext pub: xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw
         * ext prv: xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7
         * [Chain m/0'/1]
         * ext pub: xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ
         * ext prv: xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs
         * [Chain m/0'/1/2']
         * ext pub: xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5
         * ext prv: xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM
         * [Chain m/0'/1/2'/2]
         * ext pub: xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV
         * ext prv: xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334
         * [Chain m/0'/1/2'/2/1000000000]
         * ext pub: xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy
         * ext prv: xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76
         */

        // Master: 000102030405060708090a0b0c0d0e0f
        let seed = Data(hex: "000102030405060708090a0b0c0d0e0f")!

        // m
        let privateKey = HDPrivateKey(seed: seed, network: .mainnet)
        XCTAssertEqual(privateKey.extendedPublicKey().extended(), "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8")
        XCTAssertEqual(privateKey.extended(), "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi")

        // m/0'
        let m0prv = try! privateKey.derived(at: 0, hardened: true)
        XCTAssertEqual(m0prv.extendedPublicKey().extended(), "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw")
        XCTAssertEqual(m0prv.extended(), "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7")

        // m/0'/1
        let m01prv = try! m0prv.derived(at: 1)
        XCTAssertEqual(m01prv.extendedPublicKey().extended(), "xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ")
        XCTAssertEqual(m01prv.extended(), "xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs")

        // m/0'/1/2'
        let m012prv = try! m01prv.derived(at: 2, hardened: true)
        XCTAssertEqual(m012prv.extendedPublicKey().extended(), "xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5")
        XCTAssertEqual(m012prv.extended(), "xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM")

        // m/0'/1/2'/2
        let m0122prv = try! m012prv.derived(at: 2, hardened: false)
        XCTAssertEqual(m0122prv.extendedPublicKey().extended(), "xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV")
        XCTAssertEqual(m0122prv.extended(), "xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334")

        // m/0'/1/2'/2/1000000000
        let m01221000000000prv = try! m0122prv.derived(at: 1000000000)
        XCTAssertEqual(m01221000000000prv.extendedPublicKey().extended(), "xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy")
        XCTAssertEqual(m01221000000000prv.extended(), "xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76")
    }

    func testHDKey2() {
        // Test Vector 2
        /*
         Master (hex): fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542
         * [Chain m]
         * ext pub: xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB
         * ext prv: xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U
         * [Chain m/0]
         * ext pub: xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH
         * ext prv: xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt
         * [Chain m/0/2147483647']
         * ext pub: xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a
         * ext prv: xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9
         * [Chain m/0/2147483647'/1]
         * ext pub: xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon
         * ext prv: xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef
         * [Chain m/0/2147483647'/1/2147483646']
         * ext pub: xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL
         * ext prv: xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc
         * [Chain m/0/2147483647'/1/2147483646'/2]
         * ext pub: xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt
         * ext prv: xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j
         */

        // Master: fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542
        let seed = Data(hex: "fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542")!

        // m
        let privateKey = HDPrivateKey(seed: seed, network: .mainnet)
        XCTAssertEqual(privateKey.extendedPublicKey().extended(), "xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB")
        XCTAssertEqual(privateKey.extended(), "xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U")

        // m/0
        let m0prv = try! privateKey.derived(at: 0)
        XCTAssertEqual(m0prv.extendedPublicKey().extended(), "xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH")
        XCTAssertEqual(m0prv.extended(), "xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt")

        // m/0/2147483647'
        let m02147483647prv = try! m0prv.derived(at: 2147483647, hardened: true)
        XCTAssertEqual(m02147483647prv.extendedPublicKey().extended(), "xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a")
        XCTAssertEqual(m02147483647prv.extended(), "xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9")

        // m/0/2147483647'/1
        let m021474836471prv = try! m02147483647prv.derived(at: 1)
        XCTAssertEqual(m021474836471prv.extendedPublicKey().extended(), "xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon")
        XCTAssertEqual(m021474836471prv.extended(), "xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef")

        // m/0/2147483647'/1/2147483646'
        let m0214748364712147483646prv = try! m021474836471prv.derived(at: 2147483646, hardened: true)
        XCTAssertEqual(m0214748364712147483646prv.extendedPublicKey().extended(), "xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL")
        XCTAssertEqual(m0214748364712147483646prv.extended(), "xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc")

        // m/0/2147483647'/1/2147483646'/2
        let m02147483647121474836462prv = try! m0214748364712147483646prv.derived(at: 2)
        XCTAssertEqual(m02147483647121474836462prv.extendedPublicKey().extended(), "xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt")
        XCTAssertEqual(m02147483647121474836462prv.extended(), "xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j")
    }

    func testHDKey3() {
        // Test Vector 3
        // These vectors test for the retention of leading zeros. See bitpay/bitcore-lib#47 and iancoleman/bip39#58 for more information.

        // Master: 4b381541583be4423346c643850da4b320e46a87ae3d2a4e6da11eba819cd4acba45d239319ac14f863b8d5ab5a0d0c64d2e8a1e7d1457df2e5a3c51c73235be
        let seed = Data(hex: "4b381541583be4423346c643850da4b320e46a87ae3d2a4e6da11eba819cd4acba45d239319ac14f863b8d5ab5a0d0c64d2e8a1e7d1457df2e5a3c51c73235be")!

        // m
        let privateKey = HDPrivateKey(seed: seed, network: .mainnet)
        XCTAssertEqual(privateKey.extendedPublicKey().extended(), "xpub661MyMwAqRbcEZVB4dScxMAdx6d4nFc9nvyvH3v4gJL378CSRZiYmhRoP7mBy6gSPSCYk6SzXPTf3ND1cZAceL7SfJ1Z3GC8vBgp2epUt13")
        XCTAssertEqual(privateKey.extended(), "xprv9s21ZrQH143K25QhxbucbDDuQ4naNntJRi4KUfWT7xo4EKsHt2QJDu7KXp1A3u7Bi1j8ph3EGsZ9Xvz9dGuVrtHHs7pXeTzjuxBrCmmhgC6")

        // m/0'
        let m0prv = try! privateKey.derived(at: 0, hardened: true)
        XCTAssertEqual(m0prv.extendedPublicKey().extended(), "xpub68NZiKmJWnxxS6aaHmn81bvJeTESw724CRDs6HbuccFQN9Ku14VQrADWgqbhhTHBaohPX4CjNLf9fq9MYo6oDaPPLPxSb7gwQN3ih19Zm4Y")
        XCTAssertEqual(m0prv.extended(), "xprv9uPDJpEQgRQfDcW7BkF7eTya6RPxXeJCqCJGHuCJ4GiRVLzkTXBAJMu2qaMWPrS7AANYqdq6vcBcBUdJCVVFceUvJFjaPdGZ2y9WACViL4L")
    }

    func testHDKey4() {
        // Master: 000102030405060708090a0b0c0d0e0f
        let seed = Data(hex: "000102030405060708090a0b0c0d0e0f")!

        // m
        let privateKey = HDPrivateKey(seed: seed, network: .mainnet)
        // m/0'
        let m0prv = try! privateKey.derived(at: 0, hardened: true)
        // m/0'/1
        let m01prv = try! m0prv.derived(at: 1)
        let m011pub = try! m01prv.extendedPublicKey().derived(at: 1)
        XCTAssertEqual(m011pub.extended(), "xpub6D4BDPcEgbv6teFCGk7PMijta2aSGvRbvFX8dthHedYVVMM8QBf9xp9TF6TeuHYD9xiHGcuGNZQkKmD9jvojPj7YqnqtB3iYXv3f8s1JzwS")
    }

    func testHDKeychain() {
        // Master: 000102030405060708090a0b0c0d0e0f
        let seed = Data(hex: "000102030405060708090a0b0c0d0e0f")!

        let keychain = HDKeychain(seed: seed, network: .mainnet)
        let privateKey = try! keychain.derivedKey(path: "m")

        XCTAssertEqual(privateKey.extendedPublicKey().extended(), "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8")
        XCTAssertEqual(privateKey.extended(), "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi")

        // m/0'
        let m0prv = try! keychain.derivedKey(path: "m/0'")
        XCTAssertEqual(m0prv.extendedPublicKey().extended(), "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw")
        XCTAssertEqual(m0prv.extended(), "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7")

        // m/0'/1
        let m01prv = try! keychain.derivedKey(path: "m/0'/1")
        XCTAssertEqual(m01prv.extendedPublicKey().extended(), "xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ")
        XCTAssertEqual(m01prv.extended(), "xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs")

        // m/0'/1/2'
        let m012prv = try! keychain.derivedKey(path: "m/0'/1/2'")
        XCTAssertEqual(m012prv.extendedPublicKey().extended(), "xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5")
        XCTAssertEqual(m012prv.extended(), "xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM")

        // m/0'/1/2'/2
        let m0122prv = try! keychain.derivedKey(path: "m/0'/1/2'/2")
        XCTAssertEqual(m0122prv.extendedPublicKey().extended(), "xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV")
        XCTAssertEqual(m0122prv.extended(), "xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334")
    }

    func testPaymentURI() {
        let justAddress = try? PaymentURI("bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertNotNil(justAddress)
        XCTAssertEqual(justAddress?.address.network, .mainnet)
        XCTAssertEqual(justAddress?.address.base58, "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertNil(justAddress?.label)
        XCTAssertNil(justAddress?.message)
        XCTAssertNil(justAddress?.amount)
        XCTAssertTrue(justAddress?.others.isEmpty ?? false)
        XCTAssertEqual(justAddress?.uri, URL(string: "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu"))

        let addressWithName = try? PaymentURI("bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?label=Luke-Jr")
        XCTAssertNotNil(addressWithName)
        XCTAssertEqual(addressWithName?.address.network, .mainnet)
        XCTAssertEqual(addressWithName?.address.base58, "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertEqual(addressWithName?.label, "Luke-Jr")
        XCTAssertNil(addressWithName?.message)
        XCTAssertNil(addressWithName?.amount)
        XCTAssertTrue(addressWithName?.others.isEmpty ?? false)
        XCTAssertEqual(addressWithName?.uri, URL(string: "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?label=Luke-Jr"))

        let request20_30BTCToLukeJr = try? PaymentURI("bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=20.3&label=Luke-Jr")
        XCTAssertNotNil(request20_30BTCToLukeJr)
        XCTAssertEqual(request20_30BTCToLukeJr?.address.network, .mainnet)
        XCTAssertEqual(request20_30BTCToLukeJr?.address.base58, "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertEqual(request20_30BTCToLukeJr?.label, "Luke-Jr")
        XCTAssertEqual(request20_30BTCToLukeJr?.amount, Decimal(string: "20.30"))
        XCTAssertNil(request20_30BTCToLukeJr?.message)
        XCTAssertTrue(request20_30BTCToLukeJr?.others.isEmpty ?? false)
        XCTAssertEqual(request20_30BTCToLukeJr?.uri, URL(string: "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=20.3&label=Luke-Jr"))

        let request50BTCWithMessage = try? PaymentURI("bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz")
        XCTAssertNotNil(request50BTCWithMessage)
        XCTAssertEqual(request50BTCWithMessage?.address.network, .mainnet)
        XCTAssertEqual(request50BTCWithMessage?.address.base58, "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertEqual(request50BTCWithMessage?.label, "Luke-Jr")
        XCTAssertEqual(request50BTCWithMessage?.amount, Decimal(string: "50"))
        XCTAssertEqual(request50BTCWithMessage?.message, "Donation for project xyz")
        XCTAssertTrue(request50BTCWithMessage?.others.isEmpty ?? false)
        XCTAssertEqual(request50BTCWithMessage?.uri, URL(string: "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=50&label=Luke-Jr&message=Donation%20for%20project%20xyz"))

        do {
            _ = try PaymentURI("bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=abc&label=Luke-Jr")
            XCTFail("Should fail")
        } catch PaymentURIError.malformed(let key) {
            XCTAssertEqual(key, .amount)
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func testSign() {
        let msg = Data(hex: "52204d20fd0131ae1afd173fd80a3a746d2dcc0cddced8c9dc3d61cc7ab6e966")!
        let pk = Data(hex: "16f243e962c59e71e54189e67e66cf2440a1334514c09c00ddcc21632bac9808")!
        let privateKey = PrivateKey(data: pk)

        let signature = try? Crypto.sign(msg, privateKey: privateKey)

        XCTAssertNotNil(signature)
        XCTAssertEqual(signature?.hex, "3044022055f4b20035cbb2e85b7a04a0874c80d5822758f4e47a9a69db04b29f8b218f920220491e6a13296cfe2186da3a3ca565a179def3808b12d184553a8e3acfe1467273")
    }

    func testSignTransaction1() {
        // Transaction in testnet3
        // https://api.blockcypher.com/v1/btc/test3/txs/0189910c263c4d416d5c5c2cf70744f9f6bcd5feaf0b149b02e5d88afbe78992
        let prevTxID = "1524ca4eeb9066b4765effd472bc9e869240c4ecb5c1ee0edb40f8b666088231"
        // hash.reversed = txid
        let hash = Data(Data(hex: prevTxID)!.reversed())
        let index: UInt32 = 1
        let outpoint = TransactionOutPoint(hash: hash, index: index)

        let balance: Int64 = 169012961
        let amount: Int64  =  50000000
        let fee: Int64     =  10000000
        let toAddress = "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB" // https://testnet.coinfaucet.eu/en/

        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")

        let fromPublicKey = privateKey.publicKey()
        let fromPubKeyHash = Crypto.sha256ripemd160(fromPublicKey.raw)
        let toPubKeyHash = Base58.decode(toAddress)!.dropFirst().dropLast(4)

        let lockingScript1 = Script.buildPublicKeyHashOut(pubKeyHash: toPubKeyHash)
        let lockingScript2 = Script.buildPublicKeyHashOut(pubKeyHash: fromPubKeyHash)
        XCTAssertEqual(lockingScript1.hex, "76a9149f9a7abd600c0caa03983a77c8c3df8e062cb2fa88ac")
        XCTAssertEqual(lockingScript2.hex, "76a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac")

        let sending = TransactionOutput(value: amount, lockingScript: lockingScript1)
        let payback = TransactionOutput(value: balance - amount - fee, lockingScript: lockingScript2)

        // copy transaction (set script to empty)
        // if there are correspond output transactions, set script to copy
        let subScript = Data(hex: "76a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac")!
        let inputForSign = TransactionInput(previousOutput: outpoint, signatureScript: subScript, sequence: UInt32.max)
        let _tx = Transaction(version: 1, inputs: [inputForSign], outputs: [sending, payback], lockTime: 0)
        let hashType: SighashType = SighashType.BTC.ALL
        let _txHash = Crypto.sha256sha256(_tx.serialized() + UInt32(hashType).littleEndian)
        XCTAssertEqual(_txHash.hex, "fd2f20da1c28b008abcce8a8ac7e1a7687fc944e001a24fc3aacb6a7570a3d0f")
        guard let signature: Data = try? Crypto.sign(_txHash, privateKey: privateKey) else {
            XCTFail("failed to sign")
            return
        }
        XCTAssertEqual(signature.hex, "3044022074ddd327544e982d8dd53514406a77a96de47f40c186e58cafd650dd71ea522702204f67c558cc8e771581c5dda630d0dfff60d15e43bf13186669392936ec539d03")

        // scriptSig: <sig> <pubKey>
        var unlockingScript: Data = Data([UInt8(signature.count + 1)]) + signature + UInt8(hashType)
        unlockingScript += UInt8(fromPublicKey.raw.count)
        unlockingScript += fromPublicKey.raw
        let input = TransactionInput(previousOutput: outpoint, signatureScript: unlockingScript, sequence: UInt32.max)
        let transaction = Transaction(version: 1, inputs: [input], outputs: [sending, payback], lockTime: 0)
        
        let utxoToSign = TransactionOutput(value: 169012961, lockingScript: subScript)
        let sighash = transaction.signatureHash(for: utxoToSign, inputIndex: 0, hashType: hashType)
        XCTAssertEqual(sighash.hex, _txHash.hex)
        let expect = Data(hex: "010000000131820866b6f840db0eeec1b5ecc44092869ebc72d4ff5e76b46690eb4eca2415010000008a473044022074ddd327544e982d8dd53514406a77a96de47f40c186e58cafd650dd71ea522702204f67c558cc8e771581c5dda630d0dfff60d15e43bf13186669392936ec539d030141047e000cc16c9a4d38cb1572b9dc34c1452626aa170b46150d0e806be1b42517f0832c8a58f543128083ffb8632bae94dd5f3e1e89fad0a17f64ed8bbbb90b5753ffffffff0280f0fa02000000001976a9149f9a7abd600c0caa03983a77c8c3df8e062cb2fa88ace1677f06000000001976a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac00000000")!
        XCTAssertEqual(transaction.serialized().hex, expect.hex)
        XCTAssertEqual(transaction.txID, "0189910c263c4d416d5c5c2cf70744f9f6bcd5feaf0b149b02e5d88afbe78992")
    }
    
    func testSignTransaction2() {
        // Transaction on Bitcoin Cash Mainnet
        // TxID : 96ee20002b34e468f9d3c5ee54f6a8ddaa61c118889c4f35395c2cd93ba5bbb4
        // https://explorer.bitcoin.com/bch/tx/96ee20002b34e468f9d3c5ee54f6a8ddaa61c118889c4f35395c2cd93ba5bbb4
        let toAddress: Address = try! AddressFactory.create("1Bp9U1ogV3A14FMvKbRJms7ctyso4Z4Tcx")
        let changeAddress: Address = try! AddressFactory.create("1FQc5LdgGHMHEN9nwkjmz6tWkxhPpxBvBU")
        
        let unspentOutput = TransactionOutput(value: 5151, lockingScript: Data(hex: "76a914aff1e0789e5fe316b729577665aa0a04d5b0f8c788ac")!)
        let unspentOutpoint = TransactionOutPoint(hash: Data(hex: "e28c2b955293159898e34c6840d99bf4d390e2ee1c6f606939f18ee1e2000d05")!, index: 2)
        let utxo = UnspentTransaction(output: unspentOutput, outpoint: unspentOutpoint)
        let utxoKey = try! PrivateKey(wif: "L1WFAgk5LxC5NLfuTeADvJ5nm3ooV3cKei5Yi9LJ8ENDfGMBZjdW")
        
        let unsignedTx = createUnsignedTx(toAddress: toAddress, amount: 600, changeAddress: changeAddress, utxos: [utxo])
        let signedTx = signTx(unsignedTx: unsignedTx, keys: [utxoKey])
        XCTAssertEqual(signedTx.txID, "96ee20002b34e468f9d3c5ee54f6a8ddaa61c118889c4f35395c2cd93ba5bbb4")
        XCTAssertEqual(signedTx.serialized().hex, "0100000001e28c2b955293159898e34c6840d99bf4d390e2ee1c6f606939f18ee1e2000d05020000006b483045022100b70d158b43cbcded60e6977e93f9a84966bc0cec6f2dfd1463d1223a90563f0d02207548d081069de570a494d0967ba388ff02641d91cadb060587ead95a98d4e3534121038eab72ec78e639d02758e7860cdec018b49498c307791f785aa3019622f4ea5bffffffff0258020000000000001976a914769bdff96a02f9135a1d19b749db6a78fe07dc9088ace5100000000000001976a9149e089b6889e032d46e3b915a3392edfd616fb1c488ac00000000")

    }
    
    func testScript() {
        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
        let toAddress = "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB" // https://testnet.coinfaucet.eu/en/

        let fromPublicKey = privateKey.publicKey()
        let fromPubKeyHash = Crypto.sha256ripemd160(fromPublicKey.raw)
        let toPubKeyHash = Base58.decode(toAddress)!.dropFirst().dropLast(4)

        let lockingScript1 = Script.buildPublicKeyHashOut(pubKeyHash: fromPubKeyHash)
        let lockingScript2 = Script.buildPublicKeyHashOut(pubKeyHash: toPubKeyHash)

        XCTAssertEqual(Script.getPublicKeyHash(from: lockingScript1), fromPubKeyHash)
        XCTAssertEqual(Script.getPublicKeyHash(from: lockingScript2), toPubKeyHash)
    }

    func testBase58_1() {
        XCTAssertEqual(Base58.decode("1EVEDmVcV7iPvTkaw2gk89yVcCzPzaS6B7")!.hex, "0093f051563b089897cb430602a7c35cd93b3cc8e9dfac9a96")
        XCTAssertEqual(Base58.decode("11ujQcjgoMNmbmcBkk8CXLWQy8ZerMtuN")!.hex, "00002c048b88f56727538eadb2a81cfc350355ee4c466740d9")
        XCTAssertEqual(Base58.decode("111oeV7wjVNCQttqY63jLFsg817aMEmTw")!.hex, "000000abdda9e604c965f5a2fe8c082b14fafecdc39102f5b2")
    }

    func testBase58_2() {
        do {
            let original = Data(hex: "00010966776006953D5567439E5E39F86A0D273BEED61967F6")!

            let encoded = Base58.encode(original)
            XCTAssertEqual(encoded, "16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM")

            let decoded = Base58.decode(encoded)!
            XCTAssertEqual(decoded.hex, original.hex)
        }
    }

    func testConvertIP() {
        let ipv6Address = "2001:0db8:1234:5678:90ab:cdef:0000:0000"
        XCTAssertEqual(ipv6(from: Data(hex: ipv6Address.split(separator: ":").joined())!), ipv6Address)

        let ipv4mappedIPv6_1 = "0000:0000:0000:0000:0000:ffff:7f00:0001"
        XCTAssertEqual(ipv6(from: Data(hex: ipv4mappedIPv6_1.split(separator: ":").joined())!), ipv4mappedIPv6_1)
        XCTAssertEqual(ipv4(from: Data(hex: ipv4mappedIPv6_1.split(separator: ":").joined())!), "127.0.0.1")

        let ipv4mappedIPv6_2 = "0000:0000:0000:0000:0000:ffff:a00d:d2cc"
        XCTAssertEqual(ipv6(from: Data(hex: ipv4mappedIPv6_2.split(separator: ":").joined())!), ipv4mappedIPv6_2)
        XCTAssertEqual(ipv4(from: Data(hex: ipv4mappedIPv6_2.split(separator: ":").joined())!), "160.13.210.204")

        let ipv4mappedIPv6Data_1 = pton("::ffff:127.0.0.1")
        XCTAssertEqual(ipv6(from: ipv4mappedIPv6Data_1), "0000:0000:0000:0000:0000:ffff:7f00:0001")
        XCTAssertEqual(ipv4(from: ipv4mappedIPv6Data_1), "127.0.0.1")

        let ipv4mappedIPv6Data_2 = pton("2001:0db8:1234:5678:90ab:cdef:0000:0000")
        XCTAssertEqual(ipv6(from: ipv4mappedIPv6Data_2), "2001:0db8:1234:5678:90ab:cdef:0000:0000")
    }

    func testBloomFilter() {
        do {
            var filter = BloomFilter(elements: 1, falsePositiveRate: 0.0001, randomNonce: 0)
            filter.insert(Data(hex: "019f5b01d4195ecbc9398fbf3c3b1fa9bb3183301d7a1fb3bd174fcfa40a2b65")!)
            XCTAssertEqual(filter.data.hex, "b50f")
        }
        do {
            var filter = BloomFilter(elements: 3, falsePositiveRate: 0.01, randomNonce: 0)
            filter.insert(Data(hex: "99108ad8ed9bb6274d3980bab5a85c048f0950c8")!)
            filter.insert(Data(hex: "b5a2c786d9ef4658287ced5914b37a1b4aa32eee")!)
            filter.insert(Data(hex: "b9300670b4c5366e95b2699e8b18bc75e5f729c5")!)

            let message = FilterLoadMessage(filter: Data(filter.data), nHashFuncs: filter.nHashFuncs, nTweak: filter.nTweak, nFlags: 1)
            XCTAssertEqual(message.serialized().hex, Data(hex: "03614e9b050000000000000001")!.hex)
        }
        do {
            var filter = BloomFilter(elements: 3, falsePositiveRate: 0.01, randomNonce: 2147483649)
            filter.insert(Data(hex: "99108ad8ed9bb6274d3980bab5a85c048f0950c8")!)
            filter.insert(Data(hex: "b5a2c786d9ef4658287ced5914b37a1b4aa32eee")!)
            filter.insert(Data(hex: "b9300670b4c5366e95b2699e8b18bc75e5f729c5")!)

            let message = FilterLoadMessage(filter: Data(filter.data), nHashFuncs: filter.nHashFuncs, nTweak: filter.nTweak, nFlags: 1)
            XCTAssertEqual(message.serialized().hex, Data(hex: "03ce4299050000000100008001")!.hex)
        }
        do {
            var filter = BloomFilter(elements: 4, falsePositiveRate: 0.001, randomNonce: 100)
            filter.insert(Data(hex: "03cdb817b334c8e3bdc6ce3a1eae9e624cc64426eb00ef9207d2021ce6d9253a2a")!)
            filter.insert(Data(hex: "a9a917faa1751b127c55e7e19f59f2e57627e908")!)
            filter.insert(Data(hex: "02784addc6ceed8bbbee10829194ce17c99a6a7029b3a9e078b6f849aa91c937b5")!)
            filter.insert(Data(hex: "7a501a08279ec396e06c88b3e9013f31c0d4ca76")!)

            let message = FilterLoadMessage(filter: Data(filter.data), nHashFuncs: filter.nHashFuncs, nTweak: filter.nTweak, nFlags: 1)
            XCTAssertEqual(message.serialized().hex, Data(hex: "07cfe07884ebc3ac090000006400000001")!.hex)
        }
        do {
            var filter = BloomFilter(elements: 4, falsePositiveRate: 0.001, randomNonce: 100)

            let publicKey1 = PublicKey(bytes: Data(hex: "03cdb817b334c8e3bdc6ce3a1eae9e624cc64426eb00ef9207d2021ce6d9253a2a")!, network: .testnet)
            filter.insert(publicKey1.raw)
            filter.insert(Crypto.sha256ripemd160(publicKey1.raw))

            let publicKey2 = PublicKey(bytes: Data(hex: "02784addc6ceed8bbbee10829194ce17c99a6a7029b3a9e078b6f849aa91c937b5")!, network: .testnet)
            filter.insert(publicKey2.raw)
            filter.insert(Crypto.sha256ripemd160(publicKey2.raw))

            let message = FilterLoadMessage(filter: Data(filter.data), nHashFuncs: filter.nHashFuncs, nTweak: filter.nTweak, nFlags: 1)
            XCTAssertEqual(message.serialized().hex, Data(hex: "07cfe07884ebc3ac090000006400000001")!.hex)
        }
    }

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
