<p align="center">
    <img src="https://user-images.githubusercontent.com/23519083/44261174-cc64aa00-a251-11e8-85b6-145e0bcae102.jpg" alt="BitcoinKit: Let’s Play with Bitcoin in Swift!">
    <a href="https://travis-ci.org/yenom/BitcoinKit">
      <img src="http://img.shields.io/travis/yenom/BitcoinKit.svg" alt="TravisCI">
    </a>
    <a href="https://codecov.io/gh/yenom/BitcoinKit">
      <img src="https://codecov.io/gh/yenom/BitcoinKit/branch/master/graph/badge.svg" />
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-5.0+-brightgreen.svg" alt="Swift 5.0+">
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage">
    </a>
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
    <a href="http://cocoadocs.org/docsets/BitcoinKit">
        <img src="https://img.shields.io/cocoapods/v/BitcoinKit.svg" alt="CococaPods" />
    </a>
</p>


### Welcome to BitcoinKit

The BitcoinKit library is a Swift implementation of the Bitcoin protocol which support both BCH and BTC. Improving the mobile ecosystem for Bitcoin developers is our mission.

BitcoinKit allows maintaining a wallet, sending or receiving transactions without a full blockchain node. Following is a wallet app that demonstrates the way to use it.

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


Requirements
------------
- iOS 9.0+ / Mac OS X 10.11+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 10.0+
- Swift 5.0+


Installation
------------

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

```bash
$ gem install cocoapods
```

> CocoaPods 1.5.0+ is required to build BitcoinKit.

To integrate BitcoinKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'BitcoinKit', '~> 1.1.0'
end
```

Then, run the following command:
```bash
$ pod install
```

### [Carthage](https://github.com/Carthage/Carthage)
Add this to `Cartfile`

```ogdl
github "yenom/BitcoinKit" ~> 1.1.0
```

Run `carthage update` to build the framework and drag the built `BitcoinKit.framework` into your Xcode project.


### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Simply add the following lines to dependencies of your Package.swift:

```swift
.package(url: "https://github.com/yenom/BitcoinKit.git", .upToNextMinor(from: "1.1.0"))
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


