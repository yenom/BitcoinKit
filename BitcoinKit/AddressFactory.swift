//
//  AddressFactory.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/07/03.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public struct AddressFactory {
    static func create(_ plainAddress: String) throws -> Address {
        do {
            return try Cashaddr(plainAddress)
        } catch AddressError.invalidVersionByte {
            throw AddressError.invalidVersionByte
        } catch AddressError.wrongNetwork {
            throw AddressError.wrongNetwork
        } catch AddressError.invalid {
            return try LegacyAddress(plainAddress)
        }
    }
}
