BitcoinKit
===========
### Welcome to BitcoinCashKit

The BitcoinCashKit library is a Swift implementation of the Bitcoin cash protocol. This library is a fork of Katsumi Kishikawa's original BitcoinKit library aimed at supporting the Bitcoin cash eco-system.

It allows maintaining a wallet and sending/receiving transactions without needing a full blockchain node. It comes with a simple wallet app showing how to use it.

Release notes are [here](CHANGELOG.md).

<img src="https://user-images.githubusercontent.com/40610/35793683-0d497b4e-0a96-11e8-8e49-2b0ce09211a4.png" width="320px" />&nbsp;<img src="https://user-images.githubusercontent.com/40610/35793685-0da36a32-0a96-11e8-855b-ecbc3ce1474c.png" width="320px" />

Features
--------

- Send/receive transactions.
- See current balance in a wallet.
- Encoding/decoding addresses: P2PKH, P2SH, WIF format.
- Transaction building blocks: inputs, outputs, scripts.
- EC keys and signatures.
- BIP32, BIP44 hierarchical deterministic wallets.
- BIP39 implementation.

Usage
-----

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

```
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

```
let keychain = HDKeychain(seed: seed, network: .mainnet)
let privateKey = try! keychain.derivedKey(path: "m/44'/1'/0'/0/0")
...
```

#### Extended Keys

```
let extendedKey = privateKey.extended()
```

#### Sync blockchain

```
let blockStore = try! SQLiteBlockStore.default()
let blockChain = BlockChain(wallet: wallet, blockStore: blockStore)

let peerGroup = PeerGroup(blockChain: blockChain)
let peerGroup.delegate = self

let peerGroup.start()
```

Installation
------------

### Carthage

BitcoinKit is available through [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Cartfile:

`github "BitcoinCashKit/BitcoinKit"`

Contribute
----------
Contributions to BitcoinCashKit are welcome and encouraged!
Feel free to open issues, drop us pull requests.


License
-------

BitcoinKit is available under the Apache 2.0 license. See the LICENSE file for more info.
