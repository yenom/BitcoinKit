//
//  BitcoinKitTests.swift
//  BitcoinKitTests
//
//  Created by Kishikawa Katsumi on 2018/01/30.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import BitcoinKit

class BitcoinKitTests: XCTestCase {
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
        // Mainnet
        do {
            let privateKey = try! PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
            let publicKey = privateKey.publicKey()

            let address1 = Address(publicKey)
            XCTAssertEqual("\(address1)", publicKey.toAddress())

            let address2 = try? Address("1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
            XCTAssertNotNil(address2)
            XCTAssertEqual(address1, address2)

            do {
                _ = try Address("175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W")
                XCTFail("Should throw invalid checksum error.")
            } catch AddressError.invalid {
                // Success
            } catch {
                XCTFail("Should throw invalid checksum error.")
            }
        }

        // Testnet
        do {
            let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
            let publicKey = privateKey.publicKey()

            let address1 = Address(publicKey)
            XCTAssertEqual("\(address1)", publicKey.toAddress())

            let address2 = try? Address("mjNkq5ycsAfY9Vybo9jG8wbkC5mbpo4xgC")
            XCTAssertNotNil(address2)
            XCTAssertEqual(address1, address2)
        }
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
        XCTAssertEqual(privateKey.publicKey().extended(), "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8")
        XCTAssertEqual(privateKey.extended(), "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi")

        // m/0'
        let m0prv = try! privateKey.derived(at: 0, hardened: true)
        XCTAssertEqual(m0prv.publicKey().extended(), "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw")
        XCTAssertEqual(m0prv.extended(), "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7")

        // m/0'/1
        let m01prv = try! m0prv.derived(at: 1)
        XCTAssertEqual(m01prv.publicKey().extended(), "xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ")
        XCTAssertEqual(m01prv.extended(), "xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs")

        // m/0'/1/2'
        let m012prv = try! m01prv.derived(at: 2, hardened: true)
        XCTAssertEqual(m012prv.publicKey().extended(), "xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5")
        XCTAssertEqual(m012prv.extended(), "xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM")

        // m/0'/1/2'/2
        let m0122prv = try! m012prv.derived(at: 2, hardened: false)
        XCTAssertEqual(m0122prv.publicKey().extended(), "xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV")
        XCTAssertEqual(m0122prv.extended(), "xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334")

        // m/0'/1/2'/2/1000000000
        let m01221000000000prv = try! m0122prv.derived(at: 1000000000)
        XCTAssertEqual(m01221000000000prv.publicKey().extended(), "xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy")
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
        XCTAssertEqual(privateKey.publicKey().extended(), "xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB")
        XCTAssertEqual(privateKey.extended(), "xprv9s21ZrQH143K31xYSDQpPDxsXRTUcvj2iNHm5NUtrGiGG5e2DtALGdso3pGz6ssrdK4PFmM8NSpSBHNqPqm55Qn3LqFtT2emdEXVYsCzC2U")

        // m/0
        let m0prv = try! privateKey.derived(at: 0)
        XCTAssertEqual(m0prv.publicKey().extended(), "xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH")
        XCTAssertEqual(m0prv.extended(), "xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt")

        // m/0/2147483647'
        let m02147483647prv = try! m0prv.derived(at: 2147483647, hardened: true)
        XCTAssertEqual(m02147483647prv.publicKey().extended(), "xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a")
        XCTAssertEqual(m02147483647prv.extended(), "xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9")

        // m/0/2147483647'/1
        let m021474836471prv = try! m02147483647prv.derived(at: 1)
        XCTAssertEqual(m021474836471prv.publicKey().extended(), "xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon")
        XCTAssertEqual(m021474836471prv.extended(), "xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef")

        // m/0/2147483647'/1/2147483646'
        let m0214748364712147483646prv = try! m021474836471prv.derived(at: 2147483646, hardened: true)
        XCTAssertEqual(m0214748364712147483646prv.publicKey().extended(), "xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL")
        XCTAssertEqual(m0214748364712147483646prv.extended(), "xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc")

        // m/0/2147483647'/1/2147483646'/2
        let m02147483647121474836462prv = try! m0214748364712147483646prv.derived(at: 2)
        XCTAssertEqual(m02147483647121474836462prv.publicKey().extended(), "xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt")
        XCTAssertEqual(m02147483647121474836462prv.extended(), "xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j")
    }

    func testHDKey3() {
        // Test Vector 3
        // These vectors test for the retention of leading zeros. See bitpay/bitcore-lib#47 and iancoleman/bip39#58 for more information.

        // Master: 4b381541583be4423346c643850da4b320e46a87ae3d2a4e6da11eba819cd4acba45d239319ac14f863b8d5ab5a0d0c64d2e8a1e7d1457df2e5a3c51c73235be
        let seed = Data(hex: "4b381541583be4423346c643850da4b320e46a87ae3d2a4e6da11eba819cd4acba45d239319ac14f863b8d5ab5a0d0c64d2e8a1e7d1457df2e5a3c51c73235be")!

        // m
        let privateKey = HDPrivateKey(seed: seed, network: .mainnet)
        XCTAssertEqual(privateKey.publicKey().extended(), "xpub661MyMwAqRbcEZVB4dScxMAdx6d4nFc9nvyvH3v4gJL378CSRZiYmhRoP7mBy6gSPSCYk6SzXPTf3ND1cZAceL7SfJ1Z3GC8vBgp2epUt13")
        XCTAssertEqual(privateKey.extended(), "xprv9s21ZrQH143K25QhxbucbDDuQ4naNntJRi4KUfWT7xo4EKsHt2QJDu7KXp1A3u7Bi1j8ph3EGsZ9Xvz9dGuVrtHHs7pXeTzjuxBrCmmhgC6")

        // m/0'
        let m0prv = try! privateKey.derived(at: 0, hardened: true)
        XCTAssertEqual(m0prv.publicKey().extended(), "xpub68NZiKmJWnxxS6aaHmn81bvJeTESw724CRDs6HbuccFQN9Ku14VQrADWgqbhhTHBaohPX4CjNLf9fq9MYo6oDaPPLPxSb7gwQN3ih19Zm4Y")
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
        let m011pub = try! m01prv.publicKey().derived(at: 1)
        XCTAssertEqual(m011pub.extended(), "xpub6D4BDPcEgbv6teFCGk7PMijta2aSGvRbvFX8dthHedYVVMM8QBf9xp9TF6TeuHYD9xiHGcuGNZQkKmD9jvojPj7YqnqtB3iYXv3f8s1JzwS")
    }

    func testHDKeychain() {
        // Master: 000102030405060708090a0b0c0d0e0f
        let seed = Data(hex: "000102030405060708090a0b0c0d0e0f")!

        let keychain = HDKeychain(seed: seed, network: .mainnet)
        let privateKey = try! keychain.derivedKey(path: "m")

        XCTAssertEqual(privateKey.publicKey().extended(), "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8")
        XCTAssertEqual(privateKey.extended(), "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi")

        // m/0'
        let m0prv = try! keychain.derivedKey(path: "m/0'")
        XCTAssertEqual(m0prv.publicKey().extended(), "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw")
        XCTAssertEqual(m0prv.extended(), "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7")

        // m/0'/1
        let m01prv = try! keychain.derivedKey(path: "m/0'/1")
        XCTAssertEqual(m01prv.publicKey().extended(), "xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ")
        XCTAssertEqual(m01prv.extended(), "xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs")

        // m/0'/1/2'
        let m012prv = try! keychain.derivedKey(path: "m/0'/1/2'")
        XCTAssertEqual(m012prv.publicKey().extended(), "xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5")
        XCTAssertEqual(m012prv.extended(), "xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM")

        // m/0'/1/2'/2
        let m0122prv = try! keychain.derivedKey(path: "m/0'/1/2'/2")
        XCTAssertEqual(m0122prv.publicKey().extended(), "xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV")
        XCTAssertEqual(m0122prv.extended(), "xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334")
    }

    func testMnemonic1() {
        let testVectors = """
            {
                "english": [
                    [
                        "00000000000000000000000000000000",
                        "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
                        "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04",
                        "xprv9s21ZrQH143K3h3fDYiay8mocZ3afhfULfb5GX8kCBdno77K4HiA15Tg23wpbeF1pLfs1c5SPmYHrEpTuuRhxMwvKDwqdKiGJS9XFKzUsAF"
                    ],
                    [
                        "7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f",
                        "legal winner thank year wave sausage worth useful legal winner thank yellow",
                        "2e8905819b8723fe2c1d161860e5ee1830318dbf49a83bd451cfb8440c28bd6fa457fe1296106559a3c80937a1c1069be3a3a5bd381ee6260e8d9739fce1f607",
                        "xprv9s21ZrQH143K2gA81bYFHqU68xz1cX2APaSq5tt6MFSLeXnCKV1RVUJt9FWNTbrrryem4ZckN8k4Ls1H6nwdvDTvnV7zEXs2HgPezuVccsq"
                    ],
                    [
                        "80808080808080808080808080808080",
                        "letter advice cage absurd amount doctor acoustic avoid letter advice cage above",
                        "d71de856f81a8acc65e6fc851a38d4d7ec216fd0796d0a6827a3ad6ed5511a30fa280f12eb2e47ed2ac03b5c462a0358d18d69fe4f985ec81778c1b370b652a8",
                        "xprv9s21ZrQH143K2shfP28KM3nr5Ap1SXjz8gc2rAqqMEynmjt6o1qboCDpxckqXavCwdnYds6yBHZGKHv7ef2eTXy461PXUjBFQg6PrwY4Gzq"
                    ],
                    [
                        "ffffffffffffffffffffffffffffffff",
                        "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo wrong",
                        "ac27495480225222079d7be181583751e86f571027b0497b5b5d11218e0a8a13332572917f0f8e5a589620c6f15b11c61dee327651a14c34e18231052e48c069",
                        "xprv9s21ZrQH143K2V4oox4M8Zmhi2Fjx5XK4Lf7GKRvPSgydU3mjZuKGCTg7UPiBUD7ydVPvSLtg9hjp7MQTYsW67rZHAXeccqYqrsx8LcXnyd"
                    ],
                    [
                        "000000000000000000000000000000000000000000000000",
                        "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon agent",
                        "035895f2f481b1b0f01fcf8c289c794660b289981a78f8106447707fdd9666ca06da5a9a565181599b79f53b844d8a71dd9f439c52a3d7b3e8a79c906ac845fa",
                        "xprv9s21ZrQH143K3mEDrypcZ2usWqFgzKB6jBBx9B6GfC7fu26X6hPRzVjzkqkPvDqp6g5eypdk6cyhGnBngbjeHTe4LsuLG1cCmKJka5SMkmU"
                    ],
                    [
                        "7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f",
                        "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal will",
                        "f2b94508732bcbacbcc020faefecfc89feafa6649a5491b8c952cede496c214a0c7b3c392d168748f2d4a612bada0753b52a1c7ac53c1e93abd5c6320b9e95dd",
                        "xprv9s21ZrQH143K3Lv9MZLj16np5GzLe7tDKQfVusBni7toqJGcnKRtHSxUwbKUyUWiwpK55g1DUSsw76TF1T93VT4gz4wt5RM23pkaQLnvBh7"
                    ],
                    [
                        "808080808080808080808080808080808080808080808080",
                        "letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic avoid letter always",
                        "107d7c02a5aa6f38c58083ff74f04c607c2d2c0ecc55501dadd72d025b751bc27fe913ffb796f841c49b1d33b610cf0e91d3aa239027f5e99fe4ce9e5088cd65",
                        "xprv9s21ZrQH143K3VPCbxbUtpkh9pRG371UCLDz3BjceqP1jz7XZsQ5EnNkYAEkfeZp62cDNj13ZTEVG1TEro9sZ9grfRmcYWLBhCocViKEJae"
                    ],
                    [
                        "ffffffffffffffffffffffffffffffffffffffffffffffff",
                        "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo when",
                        "0cd6e5d827bb62eb8fc1e262254223817fd068a74b5b449cc2f667c3f1f985a76379b43348d952e2265b4cd129090758b3e3c2c49103b5051aac2eaeb890a528",
                        "xprv9s21ZrQH143K36Ao5jHRVhFGDbLP6FCx8BEEmpru77ef3bmA928BxsqvVM27WnvvyfWywiFN8K6yToqMaGYfzS6Db1EHAXT5TuyCLBXUfdm"
                    ],
                    [
                        "0000000000000000000000000000000000000000000000000000000000000000",
                        "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon art",
                        "bda85446c68413707090a52022edd26a1c9462295029f2e60cd7c4f2bbd3097170af7a4d73245cafa9c3cca8d561a7c3de6f5d4a10be8ed2a5e608d68f92fcc8",
                        "xprv9s21ZrQH143K32qBagUJAMU2LsHg3ka7jqMcV98Y7gVeVyNStwYS3U7yVVoDZ4btbRNf4h6ibWpY22iRmXq35qgLs79f312g2kj5539ebPM"
                    ],
                    [
                        "7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f",
                        "legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth useful legal winner thank year wave sausage worth title",
                        "bc09fca1804f7e69da93c2f2028eb238c227f2e9dda30cd63699232578480a4021b146ad717fbb7e451ce9eb835f43620bf5c514db0f8add49f5d121449d3e87",
                        "xprv9s21ZrQH143K3Y1sd2XVu9wtqxJRvybCfAetjUrMMco6r3v9qZTBeXiBZkS8JxWbcGJZyio8TrZtm6pkbzG8SYt1sxwNLh3Wx7to5pgiVFU"
                    ],
                    [
                        "8080808080808080808080808080808080808080808080808080808080808080",
                        "letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic avoid letter advice cage absurd amount doctor acoustic bless",
                        "c0c519bd0e91a2ed54357d9d1ebef6f5af218a153624cf4f2da911a0ed8f7a09e2ef61af0aca007096df430022f7a2b6fb91661a9589097069720d015e4e982f",
                        "xprv9s21ZrQH143K3CSnQNYC3MqAAqHwxeTLhDbhF43A4ss4ciWNmCY9zQGvAKUSqVUf2vPHBTSE1rB2pg4avopqSiLVzXEU8KziNnVPauTqLRo"
                    ],
                    [
                        "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
                        "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo vote",
                        "dd48c104698c30cfe2b6142103248622fb7bb0ff692eebb00089b32d22484e1613912f0a5b694407be899ffd31ed3992c456cdf60f5d4564b8ba3f05a69890ad",
                        "xprv9s21ZrQH143K2WFF16X85T2QCpndrGwx6GueB72Zf3AHwHJaknRXNF37ZmDrtHrrLSHvbuRejXcnYxoZKvRquTPyp2JiNG3XcjQyzSEgqCB"
                    ],
                    [
                        "9e885d952ad362caeb4efe34a8e91bd2",
                        "ozone drill grab fiber curtain grace pudding thank cruise elder eight picnic",
                        "274ddc525802f7c828d8ef7ddbcdc5304e87ac3535913611fbbfa986d0c9e5476c91689f9c8a54fd55bd38606aa6a8595ad213d4c9c9f9aca3fb217069a41028",
                        "xprv9s21ZrQH143K2oZ9stBYpoaZ2ktHj7jLz7iMqpgg1En8kKFTXJHsjxry1JbKH19YrDTicVwKPehFKTbmaxgVEc5TpHdS1aYhB2s9aFJBeJH"
                    ],
                    [
                        "6610b25967cdcca9d59875f5cb50b0ea75433311869e930b",
                        "gravity machine north sort system female filter attitude volume fold club stay feature office ecology stable narrow fog",
                        "628c3827a8823298ee685db84f55caa34b5cc195a778e52d45f59bcf75aba68e4d7590e101dc414bc1bbd5737666fbbef35d1f1903953b66624f910feef245ac",
                        "xprv9s21ZrQH143K3uT8eQowUjsxrmsA9YUuQQK1RLqFufzybxD6DH6gPY7NjJ5G3EPHjsWDrs9iivSbmvjc9DQJbJGatfa9pv4MZ3wjr8qWPAK"
                    ],
                    [
                        "68a79eaca2324873eacc50cb9c6eca8cc68ea5d936f98787c60c7ebc74e6ce7c",
                        "hamster diagram private dutch cause delay private meat slide toddler razor book happy fancy gospel tennis maple dilemma loan word shrug inflict delay length",
                        "64c87cde7e12ecf6704ab95bb1408bef047c22db4cc7491c4271d170a1b213d20b385bc1588d9c7b38f1b39d415665b8a9030c9ec653d75e65f847d8fc1fc440",
                        "xprv9s21ZrQH143K2XTAhys3pMNcGn261Fi5Ta2Pw8PwaVPhg3D8DWkzWQwjTJfskj8ofb81i9NP2cUNKxwjueJHHMQAnxtivTA75uUFqPFeWzk"
                    ],
                    [
                        "c0ba5a8e914111210f2bd131f3d5e08d",
                        "scheme spot photo card baby mountain device kick cradle pact join borrow",
                        "ea725895aaae8d4c1cf682c1bfd2d358d52ed9f0f0591131b559e2724bb234fca05aa9c02c57407e04ee9dc3b454aa63fbff483a8b11de949624b9f1831a9612",
                        "xprv9s21ZrQH143K3FperxDp8vFsFycKCRcJGAFmcV7umQmcnMZaLtZRt13QJDsoS5F6oYT6BB4sS6zmTmyQAEkJKxJ7yByDNtRe5asP2jFGhT6"
                    ],
                    [
                        "6d9be1ee6ebd27a258115aad99b7317b9c8d28b6d76431c3",
                        "horn tenant knee talent sponsor spell gate clip pulse soap slush warm silver nephew swap uncle crack brave",
                        "fd579828af3da1d32544ce4db5c73d53fc8acc4ddb1e3b251a31179cdb71e853c56d2fcb11aed39898ce6c34b10b5382772db8796e52837b54468aeb312cfc3d",
                        "xprv9s21ZrQH143K3R1SfVZZLtVbXEB9ryVxmVtVMsMwmEyEvgXN6Q84LKkLRmf4ST6QrLeBm3jQsb9gx1uo23TS7vo3vAkZGZz71uuLCcywUkt"
                    ],
                    [
                        "9f6a2878b2520799a44ef18bc7df394e7061a224d2c33cd015b157d746869863",
                        "panda eyebrow bullet gorilla call smoke muffin taste mesh discover soft ostrich alcohol speed nation flash devote level hobby quick inner drive ghost inside",
                        "72be8e052fc4919d2adf28d5306b5474b0069df35b02303de8c1729c9538dbb6fc2d731d5f832193cd9fb6aeecbc469594a70e3dd50811b5067f3b88b28c3e8d",
                        "xprv9s21ZrQH143K2WNnKmssvZYM96VAr47iHUQUTUyUXH3sAGNjhJANddnhw3i3y3pBbRAVk5M5qUGFr4rHbEWwXgX4qrvrceifCYQJbbFDems"
                    ],
                    [
                        "23db8160a31d3e0dca3688ed941adbf3",
                        "cat swing flag economy stadium alone churn speed unique patch report train",
                        "deb5f45449e615feff5640f2e49f933ff51895de3b4381832b3139941c57b59205a42480c52175b6efcffaa58a2503887c1e8b363a707256bdd2b587b46541f5",
                        "xprv9s21ZrQH143K4G28omGMogEoYgDQuigBo8AFHAGDaJdqQ99QKMQ5J6fYTMfANTJy6xBmhvsNZ1CJzRZ64PWbnTFUn6CDV2FxoMDLXdk95DQ"
                    ],
                    [
                        "8197a4a47f0425faeaa69deebc05ca29c0a5b5cc76ceacc0",
                        "light rule cinnamon wrap drastic word pride squirrel upgrade then income fatal apart sustain crack supply proud access",
                        "4cbdff1ca2db800fd61cae72a57475fdc6bab03e441fd63f96dabd1f183ef5b782925f00105f318309a7e9c3ea6967c7801e46c8a58082674c860a37b93eda02",
                        "xprv9s21ZrQH143K3wtsvY8L2aZyxkiWULZH4vyQE5XkHTXkmx8gHo6RUEfH3Jyr6NwkJhvano7Xb2o6UqFKWHVo5scE31SGDCAUsgVhiUuUDyh"
                    ],
                    [
                        "066dca1a2bb7e8a1db2832148ce9933eea0f3ac9548d793112d9a95c9407efad",
                        "all hour make first leader extend hole alien behind guard gospel lava path output census museum junior mass reopen famous sing advance salt reform",
                        "26e975ec644423f4a4c4f4215ef09b4bd7ef924e85d1d17c4cf3f136c2863cf6df0a475045652c57eb5fb41513ca2a2d67722b77e954b4b3fc11f7590449191d",
                        "xprv9s21ZrQH143K3rEfqSM4QZRVmiMuSWY9wugscmaCjYja3SbUD3KPEB1a7QXJoajyR2T1SiXU7rFVRXMV9XdYVSZe7JoUXdP4SRHTxsT1nzm"
                    ],
                    [
                        "f30f8c1da665478f49b001d94c5fc452",
                        "vessel ladder alter error federal sibling chat ability sun glass valve picture",
                        "2aaa9242daafcee6aa9d7269f17d4efe271e1b9a529178d7dc139cd18747090bf9d60295d0ce74309a78852a9caadf0af48aae1c6253839624076224374bc63f",
                        "xprv9s21ZrQH143K2QWV9Wn8Vvs6jbqfF1YbTCdURQW9dLFKDovpKaKrqS3SEWsXCu6ZNky9PSAENg6c9AQYHcg4PjopRGGKmdD313ZHszymnps"
                    ],
                    [
                        "c10ec20dc3cd9f652c7fac2f1230f7a3c828389a14392f05",
                        "scissors invite lock maple supreme raw rapid void congress muscle digital elegant little brisk hair mango congress clump",
                        "7b4a10be9d98e6cba265566db7f136718e1398c71cb581e1b2f464cac1ceedf4f3e274dc270003c670ad8d02c4558b2f8e39edea2775c9e232c7cb798b069e88",
                        "xprv9s21ZrQH143K4aERa2bq7559eMCCEs2QmmqVjUuzfy5eAeDX4mqZffkYwpzGQRE2YEEeLVRoH4CSHxianrFaVnMN2RYaPUZJhJx8S5j6puX"
                    ],
                    [
                        "f585c11aec520db57dd353c69554b21a89b20fb0650966fa0a9d6f74fd989d8f",
                        "void come effort suffer camp survey warrior heavy shoot primary clutch crush open amazing screen patrol group space point ten exist slush involve unfold",
                        "01f5bced59dec48e362f2c45b5de68b9fd6c92c6634f44d6d40aab69056506f0e35524a518034ddc1192e1dacd32c1ed3eaa3c3b131c88ed8e7e54c49a5d0998",
                        "xprv9s21ZrQH143K39rnQJknpH1WEPFJrzmAqqasiDcVrNuk926oizzJDDQkdiTvNPr2FYDYzWgiMiC63YmfPAa2oPyNB23r2g7d1yiK6WpqaQS"
                    ]
                ]
            }
            """

        let vectors = try! JSONSerialization.jsonObject(with: testVectors.data(using: .utf8)!, options: []) as! [String: [[String]]]
        for vector in vectors["english"]! {
            let expected = (entropy: vector[0],
                            mnemonic: vector[1],
                            seed: vector[2],
                            key: vector[3])

            let entropy = Data(hex: expected.entropy)!
            let mnemonic = Mnemonic.generate(entropy: entropy)
            XCTAssertEqual(mnemonic.joined(separator: " "), expected.mnemonic)

            let seed = Mnemonic.seed(mnemonic: mnemonic, passphrase: "TREZOR")
            XCTAssertEqual(seed.hex, expected.seed)

            let privateKey = HDPrivateKey(seed: seed, network: .mainnet)
            XCTAssertEqual(privateKey.extended(), expected.key)
        }
    }

    func testMnemonic2() {
        let testVectors = """
            [
                {
                   "entropy": "00000000000000000000000000000000",
                  "mnemonic": "あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あおぞら",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "a262d6fb6122ecf45be09c50492b31f92e9beb7d9a845987a02cefda57a15f9c467a17872029a9e92299b5cbdf306e3a0ee620245cbd508959b6cb7ca637bd55",
                "bip32_xprv": "xprv9s21ZrQH143K258jAiWPAM6JYT9hLA91MV3AZUKfxmLZJCjCHeSjBvMbDy8C1mJ2FL5ytExyS97FAe6pQ6SD5Jt9SwHaLorA8i5Eojokfo1"
                },

                {
                   "entropy": "7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f",
                  "mnemonic": "そつう　れきだい　ほんやく　わかす　りくつ　ばいか　ろせん　やちん　そつう　れきだい　ほんやく　わかめ",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "aee025cbe6ca256862f889e48110a6a382365142f7d16f2b9545285b3af64e542143a577e9c144e101a6bdca18f8d97ec3366ebf5b088b1c1af9bc31346e60d9",
                "bip32_xprv": "xprv9s21ZrQH143K3ra1D6uGQyST9UqtUscH99GK8MBh5RrgPkrQo83QG4o6H2YktwSKvoZRVXDQZQrSyCDpHdA2j8i3PW5M9LkauaaTKwym1Wf"
                },

                {
                   "entropy": "80808080808080808080808080808080",
                  "mnemonic": "そとづら　あまど　おおう　あこがれる　いくぶん　けいけん　あたえる　いよく　そとづら　あまど　おおう　あかちゃん",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "e51736736ebdf77eda23fa17e31475fa1d9509c78f1deb6b4aacfbd760a7e2ad769c714352c95143b5c1241985bcb407df36d64e75dd5a2b78ca5d2ba82a3544",
                "bip32_xprv": "xprv9s21ZrQH143K2aDKfG8hpfvRXzANmyBQWoqoUXWaSwVZcKtnmX5xTVkkHAdD9yykuuBcagjCFK6iLcBdHHxXC1g3TT9xHSu4PW6SRf3KvVy"
                },

                {
                   "entropy": "ffffffffffffffffffffffffffffffff",
                  "mnemonic": "われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　ろんぶん",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "4cd2ef49b479af5e1efbbd1e0bdc117f6a29b1010211df4f78e2ed40082865793e57949236c43b9fe591ec70e5bb4298b8b71dc4b267bb96ed4ed282c8f7761c",
                "bip32_xprv": "xprv9s21ZrQH143K4WxYzpW3izjoq6e51NSZgN6AHxoKxZStsxBvtxuQDxPyvb8o4pSbxYPCyJGKewMxrHWvTBY6WEFX4svSzB2ezmatzzJW9wi"
                },

                {
                   "entropy": "000000000000000000000000000000000000000000000000",
                  "mnemonic": "あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あらいぐま",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "d99e8f1ce2d4288d30b9c815ae981edd923c01aa4ffdc5dee1ab5fe0d4a3e13966023324d119105aff266dac32e5cd11431eeca23bbd7202ff423f30d6776d69",
                "bip32_xprv": "xprv9s21ZrQH143K2pqcK1QdBVm9r4gL4yQX6KFTqHWctvfZa9Wjhxow63ZGpSB27mVo1BBH4D1NoTo3gVAHAeqmhm5Z9SuC8xJmFYBFz978rza"
                },

                {
                   "entropy": "7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f",
                  "mnemonic": "そつう　れきだい　ほんやく　わかす　りくつ　ばいか　ろせん　やちん　そつう　れきだい　ほんやく　わかす　りくつ　ばいか　ろせん　やちん　そつう　れいぎ",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "eaaf171efa5de4838c758a93d6c86d2677d4ccda4a064a7136344e975f91fe61340ec8a615464b461d67baaf12b62ab5e742f944c7bd4ab6c341fbafba435716",
                "bip32_xprv": "xprv9s21ZrQH143K34NWKwHe5cBVDYuoKZ6iiqWczDMwGA9Ut57iCCTksDTnxE5AH3qHHvfcgwpRhyj4G7Y6FEewjVoQqq4gHN6CetyFdd3q4CR"
                },

                {
                   "entropy": "808080808080808080808080808080808080808080808080",
                  "mnemonic": "そとづら　あまど　おおう　あこがれる　いくぶん　けいけん　あたえる　いよく　そとづら　あまど　おおう　あこがれる　いくぶん　けいけん　あたえる　いよく　そとづら　いきなり",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "aec0f8d3167a10683374c222e6e632f2940c0826587ea0a73ac5d0493b6a632590179a6538287641a9fc9df8e6f24e01bf1be548e1f74fd7407ccd72ecebe425",
                "bip32_xprv": "xprv9s21ZrQH143K4RABcYmYKbZybgJrvpcnricsuNaZvsGVo7pupfELFY6TJw5G5XVswQodBzaRtfPkTi6aVCmC349A3yYzAZLfT7emP8m1RFX"
                },

                {
                   "entropy": "ffffffffffffffffffffffffffffffffffffffffffffffff",
                  "mnemonic": "われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　りんご",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "f0f738128a65b8d1854d68de50ed97ac1831fc3a978c569e415bbcb431a6a671d4377e3b56abd518daa861676c4da75a19ccb41e00c37d086941e471a4374b95",
                "bip32_xprv": "xprv9s21ZrQH143K2ThaKxBDxUByy4gNwULJyqKQzZXyF3aLyGdknnP18KvKVZwCvBJGXaAsKd7oh2ypLbjyDn4bDY1iiSPvNkKsVAGQGj7G3PZ"
                },

                {
                   "entropy": "0000000000000000000000000000000000000000000000000000000000000000",
                  "mnemonic": "あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　あいこくしん　いってい",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "23f500eec4a563bf90cfda87b3e590b211b959985c555d17e88f46f7183590cd5793458b094a4dccc8f05807ec7bd2d19ce269e20568936a751f6f1ec7c14ddd",
                "bip32_xprv": "xprv9s21ZrQH143K3skSyXVw9CTTUHgKnsysvKiJw9MQjvTSY6ysTk4sFz58htMAcqHrjLdnUhqxRtmRy5AMJyWGeuQrDGSSfmcNh7cbfnrbDty"
                },

                {
                   "entropy": "7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f",
                  "mnemonic": "そつう　れきだい　ほんやく　わかす　りくつ　ばいか　ろせん　やちん　そつう　れきだい　ほんやく　わかす　りくつ　ばいか　ろせん　やちん　そつう　れきだい　ほんやく　わかす　りくつ　ばいか　ろせん　まんきつ",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "cd354a40aa2e241e8f306b3b752781b70dfd1c69190e510bc1297a9c5738e833bcdc179e81707d57263fb7564466f73d30bf979725ff783fb3eb4baa86560b05",
                "bip32_xprv": "xprv9s21ZrQH143K2y9p1D6KuxqypMjbiBKkiALERahpxvb46x9giqkvmv5KxGvGJZG2mdcMunmHaazYyEqYmkx9SnfndimSmgJv5EL24X1DGqV"
                },

                {
                   "entropy": "8080808080808080808080808080808080808080808080808080808080808080",
                  "mnemonic": "そとづら　あまど　おおう　あこがれる　いくぶん　けいけん　あたえる　いよく　そとづら　あまど　おおう　あこがれる　いくぶん　けいけん　あたえる　いよく　そとづら　あまど　おおう　あこがれる　いくぶん　けいけん　あたえる　うめる",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "6b7cd1b2cdfeeef8615077cadd6a0625f417f287652991c80206dbd82db17bf317d5c50a80bd9edd836b39daa1b6973359944c46d3fcc0129198dc7dc5cd0e68",
                "bip32_xprv": "xprv9s21ZrQH143K2TuQM4HcbBBtvC19SaDgqn6cL16KTaPEazB26iCDfxABvBi9driWcbnF4rcLVpkx5iGG7zH2QcN7qNxL4cpb7mQ2G3ByAv7"
                },

                {
                   "entropy": "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
                  "mnemonic": "われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　われる　らいう",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "a44ba7054ac2f9226929d56505a51e13acdaa8a9097923ca07ea465c4c7e294c038f3f4e7e4b373726ba0057191aced6e48ac8d183f3a11569c426f0de414623",
                "bip32_xprv": "xprv9s21ZrQH143K3XTGpC53cWswvhg6GVQ1dE1yty6F9VhBcE7rnXmStuKwtaZNXRxw5N7tsh1REyAxun1S5BCYvhD5pNwxWUMMZaHwjTmXFdb"
                },

                {
                   "entropy": "77c2b00716cec7213839159e404db50d",
                  "mnemonic": "せまい　うちがわ　あずき　かろう　めずらしい　だんち　ますく　おさめる　ていぼう　あたる　すあな　えしゃく",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "344cef9efc37d0cb36d89def03d09144dd51167923487eec42c487f7428908546fa31a3c26b7391a2b3afe7db81b9f8c5007336b58e269ea0bd10749a87e0193",
                "bip32_xprv": "xprv9s21ZrQH143K2fhvZfecKw8znj6QkGGV2F2t17BWA6VnanejVWBjQeV5DspseWdSvN49rrFpocPGt7aSGk9R5wJfC1LAwFMt6hV9qS7yGKR"
                },

                {
                   "entropy": "b63a9c59a6e641f288ebc103017f1da9f8290b3da6bdef7b",
                  "mnemonic": "ぬすむ　ふっかつ　うどん　こうりつ　しつじ　りょうり　おたがい　せもたれ　あつめる　いちりゅう　はんしゃ　ごますり　そんけい　たいちょう　らしんばん　ぶんせき　やすみ　ほいく",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "b14e7d35904cb8569af0d6a016cee7066335a21c1c67891b01b83033cadb3e8a034a726e3909139ecd8b2eb9e9b05245684558f329b38480e262c1d6bc20ecc4",
                "bip32_xprv": "xprv9s21ZrQH143K25BDHG8fiLEPvKD9QCWqqs8V4yz2NeZXHbDgnAYW1EL5k8KWcn1kGKmsHrqbNvePJaYWEgkEMjJEepwTFfVzzyYRN7cyJgM"
                },

                {
                   "entropy": "3e141609b97933b66a060dcddc71fad1d91677db872031e85f4c015c5e7e8982",
                  "mnemonic": "くのう　てぬぐい　そんかい　すろっと　ちきゅう　ほあん　とさか　はくしゅ　ひびく　みえる　そざい　てんすう　たんぴん　くしょう　すいようび　みけん　きさらぎ　げざん　ふくざつ　あつかう　はやい　くろう　おやゆび　こすう",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "32e78dce2aff5db25aa7a4a32b493b5d10b4089923f3320c8b287a77e512455443298351beb3f7eb2390c4662a2e566eec5217e1a37467af43b46668d515e41b",
                "bip32_xprv": "xprv9s21ZrQH143K2gbMb94GNwdogai6fA3vTrALH8eoNJKqPWn9KyeBMhUQLpsN5ePJkZdHsPmyDsECNLRaYiposqDDqsbk3ANk9hbsSgmVq7G"
                },

                {
                   "entropy": "0460ef47585604c5660618db2e6a7e7f",
                  "mnemonic": "あみもの　いきおい　ふいうち　にげる　ざんしょ　じかん　ついか　はたん　ほあん　すんぽう　てちがい　わかめ",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "0acf902cd391e30f3f5cb0605d72a4c849342f62bd6a360298c7013d714d7e58ddf9c7fdf141d0949f17a2c9c37ced1d8cb2edabab97c4199b142c829850154b",
                "bip32_xprv": "xprv9s21ZrQH143K2Ec1okKMST9mN52SKEybSCeacWpAvPHMS5zFfMDfgwpJVXa96sd2sybGuJWE34CtSVYn42FBWLmFgmGeEmRvDriPnZVjWnU"
                },

                {
                   "entropy": "72f60ebac5dd8add8d2a25a797102c3ce21bc029c200076f",
                  "mnemonic": "すろっと　にくしみ　なやむ　たとえる　へいこう　すくう　きない　けってい　とくべつ　ねっしん　いたみ　せんせい　おくりがな　まかい　とくい　けあな　いきおい　そそぐ",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "9869e220bec09b6f0c0011f46e1f9032b269f096344028f5006a6e69ea5b0b8afabbb6944a23e11ebd021f182dd056d96e4e3657df241ca40babda532d364f73",
                "bip32_xprv": "xprv9s21ZrQH143K2KKucNRqjGFooHw87xXFQpZGNZ1W7Vwtkr2YMkXFuxnMvqc8cegm8jkrVswEWuNEsGtFkaEedAG2cRTTtsz1bM6o8fCu3Pg"
                },

                {
                   "entropy": "2c85efc7f24ee4573d2b81a6ec66cee209b2dcbd09d8eddc51e0215b0b68e416",
                  "mnemonic": "かほご　きうい　ゆたか　みすえる　もらう　がっこう　よそう　ずっと　ときどき　したうけ　にんか　はっこう　つみき　すうじつ　よけい　くげん　もくてき　まわり　せめる　げざい　にげる　にんたい　たんそく　ほそく",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "713b7e70c9fbc18c831bfd1f03302422822c3727a93a5efb9659bec6ad8d6f2c1b5c8ed8b0b77775feaf606e9d1cc0a84ac416a85514ad59f5541ff5e0382481",
                "bip32_xprv": "xprv9s21ZrQH143K2MXrVTP5hyWW9js9D8qipo9vVRTKYPCB8Mtw4XE57uepG7wuHRk3ZJLGAq1tdJ4So8hYHu4gBaJ4NANPjb1CJCpDd3e9H87"
                },

                {
                   "entropy": "eaebabb2383351fd31d703840b32e9e2",
                  "mnemonic": "めいえん　さのう　めだつ　すてる　きぬごし　ろんぱ　はんこ　まける　たいおう　さかいし　ねんいり　はぶらし",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "06e1d5289a97bcc95cb4a6360719131a786aba057d8efd603a547bd254261c2a97fcd3e8a4e766d5416437e956b388336d36c7ad2dba4ee6796f0249b10ee961",
                "bip32_xprv": "xprv9s21ZrQH143K3ZVFWWSR9XVXY8EMqCNdj7YUx4DKdcCFitEsSH18aPcufobUfP3w9xz1XTUThwC4cYuf8VWvSwYWs8aTTAi7mr9jDsGHYLU"
                },

                {
                   "entropy": "7ac45cfe7722ee6c7ba84fbc2d5bd61b45cb2fe5eb65aa78",
                  "mnemonic": "せんぱい　おしえる　ぐんかん　もらう　きあい　きぼう　やおや　いせえび　のいず　じゅしん　よゆう　きみつ　さといも　ちんもく　ちわわ　しんせいじ　とめる　はちみつ",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "1fef28785d08cbf41d7a20a3a6891043395779ed74503a5652760ee8c24dfe60972105ee71d5168071a35ab7b5bd2f8831f75488078a90f0926c8e9171b2bc4a",
                "bip32_xprv": "xprv9s21ZrQH143K3CXbNxjnq5iemN7AzZrtE71rvBAuZ4BnebovyS2hK3yjbAzsX6mrdxK8fa4kXPjnCC9FHpwgaPwZuCbrUJ4sj6xdPPYNeKK"
                },

                {
                   "entropy": "4fa1a8bc3e6d80ee1316050e862c1812031493212b7ec3f3bb1b08f168cabeef",
                  "mnemonic": "こころ　いどう　きあつ　そうがんきょう　へいあん　せつりつ　ごうせい　はいち　いびき　きこく　あんい　おちつく　きこえる　けんとう　たいこ　すすめる　はっけん　ていど　はんおん　いんさつ　うなぎ　しねま　れいぼう　みつかる",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "43de99b502e152d4c198542624511db3007c8f8f126a30818e856b2d8a20400d29e7a7e3fdd21f909e23be5e3c8d9aee3a739b0b65041ff0b8637276703f65c2",
                "bip32_xprv": "xprv9s21ZrQH143K2WyZ5cAUSqkC89FeL4mrEG9N9VEhh9pR2g6SQjWbXNufkfBwwaZtMfpDzip9fZjm3huvMEJASWviaGqG1A6bDmoSQzd3YFy"
                },

                {
                   "entropy": "18ab19a9f54a9274f03e5209a2ac8a91",
                  "mnemonic": "うりきれ　さいせい　じゆう　むろん　とどける　ぐうたら　はいれつ　ひけつ　いずれ　うちあわせ　おさめる　おたく",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "3d711f075ee44d8b535bb4561ad76d7d5350ea0b1f5d2eac054e869ff7963cdce9581097a477d697a2a9433a0c6884bea10a2193647677977c9820dd0921cbde",
                "bip32_xprv": "xprv9s21ZrQH143K49xMPBpnqsaXt6EECMPzVAvr18EiiJMHfgEedw28JiSCpB5DLGQB19NU2iiG4g7vVnLC6jn75B4n3LHCPwhpU6o7Srd6jYt"
                },

                {
                   "entropy": "18a2e1d81b8ecfb2a333adcb0c17a5b9eb76cc5d05db91a4",
                  "mnemonic": "うりきれ　うねる　せっさたくま　きもち　めんきょ　へいたく　たまご　ぜっく　びじゅつかん　さんそ　むせる　せいじ　ねくたい　しはらい　せおう　ねんど　たんまつ　がいけん",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "753ec9e333e616e9471482b4b70a18d413241f1e335c65cd7996f32b66cf95546612c51dcf12ead6f805f9ee3d965846b894ae99b24204954be80810d292fcdd",
                "bip32_xprv": "xprv9s21ZrQH143K2WyY1Me9W7T8Wg7yQa9WFVAEn1vhoDkkP43dBVhsagabzEKMaz7UNtczbKkNowDLXSyVipJXVEBcpYJGBJ6ZaVDXNGoLStz"
                },

                {
                   "entropy": "15da872c95a13dd738fbf50e427583ad61f18fd99f628c417a61cf8343c90419",
                  "mnemonic": "うちゅう　ふそく　ひしょ　がちょう　うけもつ　めいそう　みかん　そざい　いばる　うけとる　さんま　さこつ　おうさま　ぱんつ　しひょう　めした　たはつ　いちぶ　つうじょう　てさぎょう　きつね　みすえる　いりぐち　かめれおん",
                "passphrase": "㍍ガバヴァぱばぐゞちぢ十人十色",
                      "seed": "346b7321d8c04f6f37b49fdf062a2fddc8e1bf8f1d33171b65074531ec546d1d3469974beccb1a09263440fc92e1042580a557fdce314e27ee4eabb25fa5e5fe",
                "bip32_xprv": "xprv9s21ZrQH143K2qVq43Phs1xyVc6jSxXHWJ6CDJjod3cgyEin7hgeQV6Dkw6s1LSfMYxoah4bPAnW4wmXfDUS9ghBEM18xoY634CBtX8HPrA"
                }
            ]
            """

        let vectors = try! JSONSerialization.jsonObject(with: testVectors.data(using: .utf8)!, options: []) as! [[String: String]]
        for vector in vectors {
            let expected = (entropy: vector["entropy"]!,
                            mnemonic: vector["mnemonic"]!,
                            passphrase: vector["passphrase"]!,
                            seed: vector["seed"]!,
                            bip32_xprv: vector["bip32_xprv"]!)

            let entropy = Data(hex: expected.entropy)!
            let mnemonic = Mnemonic.generate(entropy: entropy, language: .japanese)
            XCTAssertEqual(mnemonic.joined(separator: "　"), expected.mnemonic)

            let seed = Mnemonic.seed(mnemonic: mnemonic, passphrase: expected.passphrase)
            XCTAssertEqual(seed.hex, expected.seed)

            let privateKey = HDPrivateKey(seed: seed, network: .mainnet)
            XCTAssertEqual(privateKey.extended(), expected.bip32_xprv)
        }
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
        let hash = Data(hex: "1524ca4eeb9066b4765effd472bc9e869240c4ecb5c1ee0edb40f8b666088231")!
        let index: UInt32 = 1
        let outpoint = TransactionOutPoint(hash: hash, index: index)

        let balance: Int64 = 169012961
        let amount: Int64  =  50000000
        let fee: Int64     =  10000000
        let toAddress = "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB" // https://testnet.coinfaucet.eu/en/

        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")

        let fromPublicKey = privateKey.publicKey()
        let fromPubKeyHash = Crypto.sha256ripemd160(fromPublicKey.raw)
        let toPubKeyHash = Base58.decode(toAddress).dropFirst().dropLast(4)

        let lockingScript1 = Script.buildPublicKeyHashOut(pubKeyHash: toPubKeyHash)
        let lockingScript2 = Script.buildPublicKeyHashOut(pubKeyHash: fromPubKeyHash)

        let sending = TransactionOutput(value: amount, scriptLength: VarInt(lockingScript1.count), lockingScript: lockingScript1)
        let payback = TransactionOutput(value: balance - amount - fee, scriptLength: VarInt(lockingScript2.count), lockingScript: lockingScript2)

        // copy transaction (set script to empty)
        // if there are correspond output transactions, set script to copy
        let subScript = Data(hex: "76a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac")!
        let inputForSign = TransactionInput(previousOutput: outpoint, scriptLength: VarInt(subScript.count), signatureScript: subScript, sequence: UInt32.max)
        let _tx = Transaction(version: 1, txInCount: 1, inputs: [inputForSign], txOutCount: 2, outputs: [sending, payback], lockTime: 0)

        let _txHash = Crypto.sha256sha256(_tx.serialized() + UInt32(Signature.SIGHASH_ALL).littleEndian)
        guard let signature: Data = try? Crypto.sign(_txHash, privateKey: privateKey) else {
            XCTFail("failed to sign")
            return
        }
        XCTAssertEqual(signature.hex, "3044022074ddd327544e982d8dd53514406a77a96de47f40c186e58cafd650dd71ea522702204f67c558cc8e771581c5dda630d0dfff60d15e43bf13186669392936ec539d03")

        // scriptSig: <sig> <pubKey>
        let unlockingScript: Data = Data([UInt8(signature.count + 1)]) + signature + Signature.SIGHASH_ALL + UInt8(fromPublicKey.raw.count) + fromPublicKey.raw
        let input = TransactionInput(previousOutput: outpoint, scriptLength: VarInt(unlockingScript.count), signatureScript: unlockingScript, sequence: UInt32.max)
        let transaction = Transaction(version: 1, txInCount: 1, inputs: [input], txOutCount: 2, outputs: [sending, payback], lockTime: 0)

        let expect = Data(hex: "010000000131820866b6f840db0eeec1b5ecc44092869ebc72d4ff5e76b46690eb4eca2415010000008a473044022074ddd327544e982d8dd53514406a77a96de47f40c186e58cafd650dd71ea522702204f67c558cc8e771581c5dda630d0dfff60d15e43bf13186669392936ec539d030141047e000cc16c9a4d38cb1572b9dc34c1452626aa170b46150d0e806be1b42517f0832c8a58f543128083ffb8632bae94dd5f3e1e89fad0a17f64ed8bbbb90b5753ffffffff0280f0fa02000000001976a9149f9a7abd600c0caa03983a77c8c3df8e062cb2fa88ace1677f06000000001976a9142a539adfd7aefcc02e0196b4ccf76aea88a1f47088ac00000000")!
        XCTAssertEqual(transaction.serialized().hex, expect.hex)
    }

    func testScript() {
        let privateKey = try! PrivateKey(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
        let toAddress = "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB" // https://testnet.coinfaucet.eu/en/

        let fromPublicKey = privateKey.publicKey()
        let fromPubKeyHash = Crypto.sha256ripemd160(fromPublicKey.raw)
        let toPubKeyHash = Base58.decode(toAddress).dropFirst().dropLast(4)

        let lockingScript1 = Script.buildPublicKeyHashOut(pubKeyHash: fromPubKeyHash)
        let lockingScript2 = Script.buildPublicKeyHashOut(pubKeyHash: toPubKeyHash)

        XCTAssertEqual(Script.getPublicKeyHash(from: lockingScript1), fromPubKeyHash)
        XCTAssertEqual(Script.getPublicKeyHash(from: lockingScript2), toPubKeyHash)
    }

    func testBase58_1() {
        XCTAssertEqual(Base58.decode("1EVEDmVcV7iPvTkaw2gk89yVcCzPzaS6B7").hex, "0093f051563b089897cb430602a7c35cd93b3cc8e9dfac9a96")
        XCTAssertEqual(Base58.decode("11ujQcjgoMNmbmcBkk8CXLWQy8ZerMtuN").hex, "00002c048b88f56727538eadb2a81cfc350355ee4c466740d9")
        XCTAssertEqual(Base58.decode("111oeV7wjVNCQttqY63jLFsg817aMEmTw").hex, "000000abdda9e604c965f5a2fe8c082b14fafecdc39102f5b2")
    }

    func testBase58_2() {
        do {
            let original = Data(hex: "00010966776006953D5567439E5E39F86A0D273BEED61967F6")!

            let encoded = Base58.encode(original)
            XCTAssertEqual(encoded, "16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM")

            let decoded = Base58.decode(encoded)
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
