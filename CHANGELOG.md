## 1.1.0 Release notes (2019-09-29)
#### ⬆️ Swift 5.0
Now we support Swift5.0!

#### ⭐️ New Features
- Plan, Build and Sign a transaction #228 
- QRCode support #158 
- ECPoint multiplication methods #219 

#### ♻️ Refactor
- Mnemonic #227 
- HDWallet #228 
- Address #232 

#### 🐛 Fix bugs
- Key derivation bug #220 

#### And more...!
- Add merkleblock and proof of work check #170 #153 
- Add BlockMessage.computeMerkleRoot() #215 
- Using secp256k1 library instead of openssl #218 #203 
- Fix typos #179 
- Modify README #180 #208 #211 

#### ✅ All Merged PRs 
All PRs since v1.0.2
- #158 
- #159 
- #161 
- #167 
- #169 
- #171 
- #173 
- #211 
- #208 
- #179 
- #168 
- #215 
- #170 
- #218 
- #219 
- #220
- #220 
- #222 
- #223 
- #226 
- #227 
- #228 
- #229 
- #232 

## 1.0.2 Release notes (2018-09-06)
- Added Multisig Script Mock!
- Added isCoinbase() in Transaction class by @federicobond
- Fix some typo by @federicobond
- Add HeadersMessage by @akifuj
- Add open collective committers and backers by @monkeywithacupcake

## 1.0.1 Release notes (2018-08-17)
- ScriptFactory is added!

## 1.0.0 Release notes (2018-08-17)
- First major release!
- All OP_CODEs are available now!
- Script is available now!
- etc...

## 0.2.1 Release notes (2018-07-30)
- Fix Carthage install problem
- Add OP_CODEs
- Refactor ScriptMachine
- etc...

## 0.2.0 Release notes (2018-07-29)
First Version for BitcoinKit!
Bunch of changes included.

- Cashaddr
- Bech32
- BIP143 based Transaction Digest Algorithm
- Script Machine
- UnitTests
- Minor bug fixes
- etc...

## 0.1.2 Release notes (2018-02-10)

##### Breaking

* None.  

##### Enhancements

* None.  

##### Bug Fixes

* Hide OpenSSL headers in private module. No longer needed to add header search paths in a user project.  
  [#20](https://github.com/kishikawakatsumi/BitcoinKit/pull/20)

## 0.1.1 Release notes (2018-02-06)

##### Breaking

* None.  

##### Enhancements

* Extend supported lower iOS version to 8.0  
  [#8](https://github.com/kishikawakatsumi/BitcoinKit/pull/8)
* Support CocoaPods  
  [#7](https://github.com/kishikawakatsumi/BitcoinKit/pull/7)

##### Bug Fixes

* Fix carthage installation failure  
  [#5](https://github.com/kishikawakatsumi/BitcoinKit/pull/5)

## 0.1.0 Release notes (2018-02-05)

First Version!
