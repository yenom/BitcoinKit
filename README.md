![BitcoinCashKit: Let's Play with Bitcoin in Swift!](https://user-images.githubusercontent.com/23519083/43385824-be9ac974-941c-11e8-835c-39188c4ed7c9.jpg)

[![CI Status](http://img.shields.io/travis/BitcoinCashKit/BitcoinCashKit.svg)](https://travis-ci.org/BitcoinCashKit/BitcoinCashKit)
[![codecov](https://codecov.io/gh/BitcoinCashKit/BitcoinCashKit/branch/master/graph/badge.svg)](https://codecov.io/gh/BitcoinCashKit/BitcoinCashKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/BitcoinCashKit.svg)](http://cocoadocs.org/docsets/BitcoinCashKit)
[![Platform](https://img.shields.io/cocoapods/p/BitcoinCashKit.svg)](http://cocoadocs.org/docsets/BitcoinCashKit)

### Welcome to BitcoinCashKit

The BitcoinCashKit library is a Swift implementation of the Bitcoin cash protocol. This library is a fork of Katsumi Kishikawa's original BitcoinKit library aimed at supporting the Bitcoin cash eco-system.

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

> CocoaPods 1.5.0+ is required to build BitcoinCashKit.

To integrate BitcoinCashKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'BitcoinCashKit'
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

To integrate BitcoinCashKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "BitcoinCashKit/BitcoinCashKit"
```

Run `carthage update` to build the framework and drag the built `BitcoinCashKit.framework` into your Xcode project.

Contribute
----------
Contributions to BitcoinCashKit are welcome and encouraged!
Feel free to open issues, drop us pull requests.

## Authors & Maintainers
 - [usatie](https://github.com/usatie)
 - [akifuji](https://github.com/akifuj)

License
-------

BitcoinCashKit is available under the MIT license. See the LICENSE file for more info.
