//
//  HDWalletTests.swift
//
//  Copyright © 2019 BitcoinKit developers
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

class HDWalletTests: XCTestCase {
    var wallet: HDWallet!
    override func setUp() {
        let mnemonic: [String] = ["abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "about"]
        wallet = try! HDWallet(mnemonic: mnemonic,
                                        passphrase: "TREZOR",
                                        externalIndex: 0,
                                        internalIndex: 0,
                                        network: .mainnetBCH)
    }
    
    func testInitFromMnemonic() {
        let mnemonic: [String] = ["abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "about"]
        let walletFromMnemonic: HDWallet = try! HDWallet(mnemonic: mnemonic,
                              passphrase: "TREZOR",
                              externalIndex: 0,
                              internalIndex: 0,
                              network: .mainnetBCH)


        XCTAssertEqual(walletFromMnemonic.mnemonic,
                       ["abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "about"]
        )

        XCTAssertEqual(walletFromMnemonic.rootXPrivKey.description, "xprv9s21ZrQH143K3h3fDYiay8mocZ3afhfULfb5GX8kCBdno77K4HiA15Tg23wpbeF1pLfs1c5SPmYHrEpTuuRhxMwvKDwqdKiGJS9XFKzUsAF")
        XCTAssertEqual(walletFromMnemonic.rootXPubKey.description, "xpub661MyMwAqRbcGB88KaFbLGiYAat55APKhtWg4uYMkXAmfuSTbq2QYsn9sKJCj1YqZPafsboef4h4YbXXhNhPwMbkHTpkf3zLhx7HvFw1NDy")
        XCTAssertEqual(walletFromMnemonic.seed.hex, "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04")
    }
    
    func testInitFromSeed() {
        let seed: Data = Data(hex: "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04")!
        let walletFromSeed: HDWallet = HDWallet(seed: seed,
                                                    externalIndex: 0,
                                                    internalIndex: 0,
                                                    network: .mainnetBCH)
        XCTAssertNil(walletFromSeed.mnemonic)
        XCTAssertEqual(walletFromSeed.rootXPrivKey.description, "xprv9s21ZrQH143K3h3fDYiay8mocZ3afhfULfb5GX8kCBdno77K4HiA15Tg23wpbeF1pLfs1c5SPmYHrEpTuuRhxMwvKDwqdKiGJS9XFKzUsAF")
        XCTAssertEqual(walletFromSeed.rootXPubKey.description, "xpub661MyMwAqRbcGB88KaFbLGiYAat55APKhtWg4uYMkXAmfuSTbq2QYsn9sKJCj1YqZPafsboef4h4YbXXhNhPwMbkHTpkf3zLhx7HvFw1NDy")
        XCTAssertEqual(walletFromSeed.seed.hex, "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04")
    }
    
    func testCreateWallet() {
        let created: HDWallet = HDWallet.create(passphrase: "BitcoinKit-Wallet", network: .mainnetBCH)
        XCTAssertEqual(created.mnemonic?.count, 12)
        XCTAssertEqual(created.externalIndex, 0)
        XCTAssertEqual(created.internalIndex, 0)
        XCTAssertEqual(created.addresses.count, 2)

        let copied: HDWallet = try! HDWallet(mnemonic: created.mnemonic!,
                                        passphrase: "BitcoinKit-Wallet",
                                        externalIndex: created.externalIndex,
                                        internalIndex: created.internalIndex,
                                        network: created.network)
        XCTAssertEqual(created.mnemonic, copied.mnemonic)
        XCTAssertEqual(created.seed, copied.seed)
        XCTAssertEqual(created.rootXPrivKey.description, copied.rootXPrivKey.description)
        XCTAssertEqual(created.rootXPubKey.description, copied.rootXPubKey.description)
        XCTAssertEqual(created.addresses.map { $0.cashaddr }, copied.addresses.map { $0.cashaddr })
        XCTAssertEqual(created.address(index: 53, chain: .internal).cashaddr, copied.address(index: 53, chain: .internal).cashaddr)
        XCTAssertEqual(created.address(index: 152, chain: .external).cashaddr, copied.address(index: 152, chain: .external).cashaddr)
    }
    
    func testAddress() {
        XCTAssertEqual(wallet.externalIndex, 0)
        XCTAssertEqual(wallet.internalIndex, 0)
        XCTAssertEqual(wallet.addresses.count, 2)

        XCTAssertEqual(wallet.address.cashaddr,
                       "bitcoincash:qpmtwknkc0zfk0j8v6e6p8rye6q48de85stk6qcprd")
        XCTAssertEqual(wallet.changeAddress.cashaddr,
                       "bitcoincash:qrh8eaxumhys4zcvyemy0sjsh0auq8pe05rrs9glke")
        XCTAssertEqual(wallet.addresses.map { $0.cashaddr }, [
            "bitcoincash:qpmtwknkc0zfk0j8v6e6p8rye6q48de85stk6qcprd",
            "bitcoincash:qrh8eaxumhys4zcvyemy0sjsh0auq8pe05rrs9glke"
            ])
        
        XCTAssertEqual(wallet.address(index: 3, chain: .internal).cashaddr,
                       "bitcoincash:qp6txfp8kxlvuz8yy7q8q8g0fdrwzcrv8g5vhmwy2w")
        XCTAssertEqual(wallet.address(index: 5, chain: .external).cashaddr,
                       "bitcoincash:qzzk9ylgauq63lu6tt8td82e0gz2e9pctyusls34zm")
    }
    
    func testIncrementExternalIndex() {
        // Increment Receive Key
        wallet.incrementExternalIndex(by: 1)
        XCTAssertEqual(wallet.externalIndex, 1)
        XCTAssertEqual(wallet.internalIndex, 0)
        XCTAssertEqual(wallet.address.cashaddr,
                       "bitcoincash:qz4q4kzwdfc32ejsapzq0uupxca6gj0ym5kawa5zur")
        XCTAssertEqual(wallet.addresses.count, 3)
        XCTAssertEqual(wallet.addresses.map { $0.cashaddr },
                       ["bitcoincash:qpmtwknkc0zfk0j8v6e6p8rye6q48de85stk6qcprd",
                        "bitcoincash:qz4q4kzwdfc32ejsapzq0uupxca6gj0ym5kawa5zur",
                        "bitcoincash:qrh8eaxumhys4zcvyemy0sjsh0auq8pe05rrs9glke"]
        )
    }
    
    func testIncrementInternalIndex() {
        wallet.incrementInternalIndex(by: 1)
        XCTAssertEqual(wallet.externalIndex, 0)
        XCTAssertEqual(wallet.internalIndex, 1)
        XCTAssertEqual(wallet.changeAddress.cashaddr, "bitcoincash:qqvukzdlzh80gfkf70hwnmhh36qz6hy7rgrumlt4dz")
        XCTAssertEqual(wallet.addresses.count, 3)
        XCTAssertEqual(wallet.addresses.map { $0.cashaddr },
                       ["bitcoincash:qpmtwknkc0zfk0j8v6e6p8rye6q48de85stk6qcprd",
                        "bitcoincash:qrh8eaxumhys4zcvyemy0sjsh0auq8pe05rrs9glke",
                        "bitcoincash:qqvukzdlzh80gfkf70hwnmhh36qz6hy7rgrumlt4dz"]
        )
    }
}
