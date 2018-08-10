BitcoinKit
===========
[![CI Status](http://img.shields.io/travis/kishikawakatsumi/BitcoinKit.svg)](https://travis-ci.org/kishikawakatsumi/BitcoinKit)
[![codecov](https://codecov.io/gh/kishikawakatsumi/BitcoinKit/branch/master/graph/badge.svg)](https://codecov.io/gh/kishikawakatsumi/BitcoinKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/BitcoinKit.svg)](http://cocoadocs.org/docsets/BitcoinKit)
[![Platform](https://img.shields.io/cocoapods/p/BitcoinKit.svg)](http://cocoadocs.org/docsets/BitcoinKit)

BitcoinKit implements Bitcoin protocol in Swift. It is an implementation of the Bitcoin SPV protocol written (almost) entirely in swift.

Features
--------

- Send/receive transactions.
- See current balance in a wallet.
- Encoding/decoding addresses: P2PKH, WIF format.
- Transaction building blocks: inputs, outputs, scripts.
- EC keys and signatures.
- BIP32, BIP44 hierarchical deterministic wallets.
- BIP39 implementation.

Usage
-----

	//助记词
	let words = Mnemonic.generate(strength: Mnemonic.Strength.default, language: language)
	//种子
	let seed = Mnemonic.seed(mnemonic: words)
	//网络, 支持 BTC, BCH, LTC...
	let net = CommonNet(symbol: token.symbol, bip32HeaderPub: token.bip32HeaderPub, bip32HeaderPriv: token.bip32HeaderPriv, wif: token.wif, addressHeader: token.addressHeader, p2shHeader: token.p2shHeader)
	let hdKeyChain = HDKeychain(seed: seed, network: net)
	//生成外部地址
	let path = String(format: "m/44'/%d'/0'/0/%d",coin_type, address_index)
	let address = derivedKey(path: path).publicKey().toAddress()
        
Installation
------------

### CocoaPods

BitcoinKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following lines to your Podfile:

```ruby
use_frameworks!
pod 'BitcoinKit'
```

### Environment

BitcoinKit builds secp256k1 and OpenSSL itself for security reasons. They requires autoconf and automake. Please install them.

	brew install libtool autoconf automake
	
**Make sure you're using the latest version of Xcode**


License
-------

BitcoinKit is available under the Apache 2.0 license. See the LICENSE file for more info.


Modify
-------

#### Swift4.1 bug  

Script.swift 出现 Swift 语法错误. 修改如下: 

	public static func buildPublicKeyHashOut(pubKeyHash: Data) -> Data {
        var tmp = Data() + OP_DUP + OP_HASH160 + OP_0 + pubKeyHash + OP_EQUALVERIFY
        return tmp + OP_CHECKSIG
    }


#### 助记词验证

Mnemonic.swift 新增助记词验证方法: 

	//in struct Mnemonic
	
	//验证助记词合法, 语言识别
	public static func isLegal(word: String, forLanguage: Language?) -> (Bool, Language) {
        let lang = forLanguage
        if lang != nil {
            let has = isLegal(word: word, language: lang!)
            return (has, lang!)
        }
        var languageArr = [Language]()
        languageArr.append(.english)
        languageArr.append(.japanese)
        languageArr.append(.korean)
        languageArr.append(.spanish)
        languageArr.append(.simplifiedChinese)
        languageArr.append(.french)
        languageArr.append(.traditionalChinese)
        languageArr.append(.italian)
        
        for lang in languageArr {
            if isLegal(word: word, language: lang) {
                return (true, lang)
            }
        }
        return (false, .english)
    }
    
    //确定的语言验证助记词合法性
    public static func isLegal(word: String, language: Language) -> Bool {
        let list = wordList(for: language)
        for w in list {
            let newStr = String(w)
            if newStr == word {
                return true
            }
        }
        return false
    }

	public static func isLegal(mnemonic m: [String], for language: Language = .english) -> Bool {
        let list = wordList(for: language)
        if m.count != 12 {
            return false
        }
        for word in m {
            var count = 0
            for w in m {
                if word == w {
                    count = count + 1
                }
            }
            if count != 1 {
                return false
            }
        }
        for word in m {
            var foundOne = false
            for w in list {
                let newStr = String(w)
                if newStr == word {
                    foundOne = true
                    break
                }
            }
            if !foundOne {
                return false
            }
        }
        return true
    }

#### 拓展支持其他币种

支持其他币种拓展, Network.swift 增加 CommonNet: 

	public class CommonNet: Network {
    	var psymbol: String
		var ppubkeyhash: UInt8
		var pprivatekey: UInt8
   		var pscripthash: UInt8
		var pxpubkey: UInt32
   		var pxprivkey: UInt32
    
		public init(symbol: String, bip32HeaderPub: Int, bip32HeaderPriv: Int, wif: Int, addressHeader: Int, p2shHeader: Int) {
			self.psymbol = symbol
			self.pxpubkey = UInt32(bip32HeaderPub)
			self.pxprivkey = UInt32(bip32HeaderPriv)
			self.pprivatekey = UInt8(wif)
			self.ppubkeyhash = UInt8(addressHeader)
			self.pscripthash = UInt8(p2shHeader)
	    }
		public override var name: String {
			return psymbol
		}
		public override var alias: String {
			return psymbol
		}
		override var pubkeyhash: UInt8 {
			return ppubkeyhash
		}
		override var privatekey: UInt8 {
			return pprivatekey
		}
		override var scripthash: UInt8 {
			return pscripthash
		}
		override var xpubkey: UInt32 {
			return pxpubkey
		}
		override var xprivkey: UInt32 {
			return pxprivkey
		}
	}

