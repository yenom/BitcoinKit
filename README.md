![BitcoinKit: Let’s Play with Bitcoin in Swift!](https://user-images.githubusercontent.com/23519083/44261174-cc64aa00-a251-11e8-85b6-145e0bcae102.jpg)

[![CI Status](http://img.shields.io/travis/yenom/BitcoinKit.svg)](https://travis-ci.org/yenom/BitcoinKit)
[![codecov](https://codecov.io/gh/yenom/BitcoinKit/branch/master/graph/badge.svg)](https://codecov.io/gh/yenom/BitcoinKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/BitcoinKit.svg)](http://cocoadocs.org/docsets/BitcoinKit)
[![Platform](https://img.shields.io/cocoapods/p/BitcoinKit.svg)](http://cocoadocs.org/docsets/BitcoinKit)
[![Backers on Open Collective](https://opencollective.com/BitcoinKit/backers/badge.svg)](#backers) 
[![Sponsors on Open Collective](https://opencollective.com/BitcoinKit/sponsors/badge.svg)](#sponsors) 

### Welcome to BitcoinKit

The BitcoinKit library is a Swift implementation of the Bitcoin protocol, supporting both of BCH and BTC. 
Our mission is improving the mobile ecosystem for Bitcoin developers.

It allows maintaining a wallet and sending/receiving transactions without needing a full blockchain node. It comes with a simple wallet app showing how to use it.

Release notes are [here](CHANGELOG.md).

<img src="https://user-images.githubusercontent.com/24402451/43367286-8753b4cc-9385-11e8-9fba-78e5283c1158.png" width="320px" />&nbsp;<img src="https://user-images.githubusercontent.com/24402451/43367196-523d5f46-9384-11e8-9fee-10e72318e67b.png" width="319px" />

Features
--------

- Encoding/decoding addresses: base58, Cashaddr, P2PKH, P2SH, WIF format.
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

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate BitcoinKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "yenom/BitcoinKit"
```

Run `carthage update` to build the framework and drag the built `BitcoinKit.framework` into your Xcode project.


### Swift Package Manager

BitcoinKit is available through [Swift Package Manager](https://github.com/apple/swift-package-manager). To install
it, simply add the following lines to dependencies of your Package.swift:

```swift
.package(url: "https://github.com/yenom/BitcoinKit.git", .upToNextMinor(from: "0.1.0"))
```

Note that following data types and features are currently not supported on Linux platform.  

* `Peer` and `PeerGroup`
* SQLite based BlockStore

Contribute
----------
Contributions to BitcoinKit are welcome and encouraged!
Feel free to open issues, drop us pull requests.

## Authors & Maintainers
 - [usatie](https://github.com/usatie)
 - [akifuji](https://github.com/akifuj)

 ## About

 <img width=220 src="https://user-images.githubusercontent.com/24402451/44437525-9169ca00-a5f5-11e8-8a77-9c1b906fb864.jpg"></img>

 BitcoinKit is maintained and funded by Yenom.
 Visit our [website](https://yenom.tech) or say hi on twitter ([@Yenom_wallet_en](https://twitter.com/Yenom_wallet_en))

License
-------

BitcoinKit is available under the MIT license. See the LICENSE file for more info.

## Contributors

This project exists thanks to all the people who contribute. 
<a href="graphs/contributors"><img src="https://opencollective.com/BitcoinKit/contributors.svg?width=890&button=false" /></a>


## Backers

Thank you to all our backers! 🙏 [[Become a backer](https://opencollective.com/BitcoinKit#backer)]

<a href="https://opencollective.com/BitcoinKit#backers" target="_blank"><img src="https://opencollective.com/BitcoinKit/backers.svg?width=890"></a>


## Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website. [[Become a sponsor](https://opencollective.com/BitcoinKit#sponsor)]

<a href="https://opencollective.com/BitcoinKit/sponsor/0/website" target="_blank"><img src="https://opencollective.com/BitcoinKit/sponsor/0/avatar.svg"></a>
<a href="https://opencollective.com/BitcoinKit/sponsor/1/website" target="_blank"><img src="https://opencollective.com/BitcoinKit/sponsor/1/avatar.svg"></a>
<a href="https://opencollective.com/BitcoinKit/sponsor/2/website" target="_blank"><img src="https://opencollective.com/BitcoinKit/sponsor/2/avatar.svg"></a>
<a href="https://opencollective.com/BitcoinKit/sponsor/3/website" target="_blank"><img src="https://opencollective.com/BitcoinKit/sponsor/3/avatar.svg"></a>
<a href="https://opencollective.com/BitcoinKit/sponsor/4/website" target="_blank"><img src="https://opencollective.com/BitcoinKit/sponsor/4/avatar.svg"></a>
<a href="https://opencollective.com/BitcoinKit/sponsor/5/website" target="_blank"><img src="https://opencollective.com/BitcoinKit/sponsor/5/avatar.svg"></a>
<a href="https://opencollective.com/BitcoinKit/sponsor/6/website" target="_blank"><img src="https://opencollective.com/BitcoinKit/sponsor/6/avatar.svg"></a>
<a href="https://opencollective.com/BitcoinKit/sponsor/7/website" target="_blank"><img src="https://opencollective.com/BitcoinKit/sponsor/7/avatar.svg"></a>
<a href="https://opencollective.com/BitcoinKit/sponsor/8/website" target="_blank"><img src="https://opencollective.com/BitcoinKit/sponsor/8/avatar.svg"></a>
<a href="https://opencollective.com/BitcoinKit/sponsor/9/website" target="_blank"><img src="https://opencollective.com/BitcoinKit/sponsor/9/avatar.svg"></a>


