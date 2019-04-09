![BitcoinKit: Let’s Play with Bitcoin in Swift!](https://user-images.githubusercontent.com/23519083/44261174-cc64aa00-a251-11e8-85b6-145e0bcae102.jpg)

[![Build Status](https://travis-ci.com/Bitcoin-com/BitcoinKit.svg?branch=master)](https://travis-ci.com/Bitcoin-com/BitcoinKit)
[![codecov](https://codecov.io/gh/yenom/BitcoinKit/branch/master/graph/badge.svg)](https://codecov.io/gh/bitcoin-com/BitcoinKit)
![Version](https://img.shields.io/badge/version-v1.1.1-blue.svg)
![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg) 

### Welcome to BitcoinKit

The BitcoinKit library is a Swift implementation of the Bitcoin protocol, supporting both of BCH and BTC. 
Our mission is improving the mobile ecosystem for Bitcoin developers.

It allows maintaining a wallet and sending/receiving transactions without needing a full blockchain node. It comes with a simple wallet app showing how to use it.

Release notes are [here](CHANGELOG.md).

<img src="https://user-images.githubusercontent.com/24402451/43367286-8753b4cc-9385-11e8-9fba-78e5283c1158.png" width="320px" />&nbsp;<img src="https://user-images.githubusercontent.com/24402451/43367196-523d5f46-9384-11e8-9fee-10e72318e67b.png" width="319px" />

Features
--------

- Encoding/decoding addresses: base58, Cashaddr, SLP, P2PKH, P2SH, WIF format.
- Transaction building blocks: inputs, outputs, scripts.
- EC keys and signatures.
- BIP32, BIP44 hierarchical deterministic wallets.
- BIP39 implementation.
- SPV features **are under construction**. The following functions cannot work well sometimes.
  - Send/receive transactions.
  - See current balance in a wallet.

Usage
-----

#### Generate addresses
```swift
// from Testnet Cashaddr
let cashaddrTest = try AddressFactory.create("bchtest:pr6m7j9njldwwzlg9v7v53unlr4jkmx6eyvwc0uz5t")

// from Mainnet Cashaddr
let cashaddrMain = try AddressFactory.create("bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")

// from Base58 format
let address = try AddressFactory.create("1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
```

#### Creating new wallet

```swift
let privateKey = PrivateKey(network: .testnet) // You can choose .mainnet or .testnet
let wallet = Wallet(privateKey: privateKey)
```

#### Import wallet from WIF

```swift
let wallet = try Wallet(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
```

#### Hierarchical Deterministic Wallet

```swift
// Generate mnemonic
let mnemonic = try Mnemonic.generate()

// Generate seed from the mnemonic
let seed = Mnemonic.seed(mnemonic: mnemonic)

let wallet = HDWallet(seed: seed, network: .testnet)
```

#### Key derivation

```swift
let mnemonic = try Mnemonic.generate()
let seed = Mnemonic.seed(mnemonic: mnemonic)

let privateKey = HDPrivateKey(seed: seed, network: .testnet)

// m/0'
let m0prv = try! privateKey.derived(at: 0, hardened: true)

// m/0'/1
let m01prv = try! m0prv.derived(at: 1)

// m/0'/1/2'
let m012prv = try! m01prv.derived(at: 2, hardened: true)
```

#### HD Wallet Key derivation

```swift
let keychain = HDKeychain(seed: seed, network: .mainnet)
let privateKey = try! keychain.derivedKey(path: "m/44'/1'/0'/0/0")
```

#### Extended Keys

```swift
let extendedKey = privateKey.extended()
```

#### Sync blockchain

```swift
let blockStore = try! SQLiteBlockStore.default()
let blockChain = BlockChain(network: .testnet, blockStore: blockStore)

let peerGroup = PeerGroup(blockChain: blockChain)
let peerGroup.delegate = self

let peerGroup.start()
```

Requirements
------------
- iOS 9.0+ / Mac OS X 10.11+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 9.0+
- Swift 4.1+

Installation
------------

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.5.0+ is required to build BitcoinKit.

To integrate BitcoinKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/Bitcoin-com/CocoaPods.git'
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'BitcoinKit'
end
```

Then, run the following command:
```bash
$ pod install
```

### Swift Package Manager

BitcoinKit is available through [Swift Package Manager](https://github.com/apple/swift-package-manager). To install
it, simply add the following lines to dependencies of your Package.swift:

```swift
.package(url: "https://github.com/Bitcoin-com/BitcoinKit.git", .upToNextMinor(from: "0.1.0"))
```

Note that following data types and features are currently not supported on Linux platform.  

* `Peer` and `PeerGroup`
* SQLite based BlockStore

Contribute
----------
Contributions to BitcoinKit are welcome and encouraged!
Feel free to open issues, drop us pull requests.

## Authors
 - Kishikawa Katsumi
 - [usatie](https://github.com/usatie)
 - [akifuji](https://github.com/akifuj)
 - Jean-Baptiste Dominguez [[Github](https://github.com/jbdtky), [Twitter](https://twitter.com/jbdtky)]
 - Angel Mortega [[Github](https://github.com/holemcross)]

## Maintainers
 - Jean-Baptiste Dominguez [[Github](https://github.com/jbdtky), [Twitter](https://twitter.com/jbdtky)]
 - Angel Mortega [[Github](https://github.com/holemcross)]

 ## About

 Visit our [website](https://bitcoin.com) or on twitter ([@BitcoinCom](https://twitter.com/BitcoinCom))

License
-------

BitcoinKit is available under the MIT license. See the LICENSE file for more info.

## Contributors

This project exists thanks to all the people who contribute. 
<a href="graphs/contributors">See the contributors</a>



