//
//  Transaction.swift
//  Yenom
//
//  Created by yuzushioh on 2018/05/12.
//  Copyright © 2018 Yenom. All rights reserved.
//

import Foundation

struct Transactions: Codable {
    let transactions: [CodableTx]

    private enum CodingKeys: String, CodingKey {
        case transactions = "txs"
    }
}

struct CodableTx: Codable {

    let blockHash: String?
    let blockHeight: Int64?
    let blockTime: Int64?
    let confirmations: Int64
    let time: Int64
    let txid: String
    let inputs: [Input]
    let outputs: [Output]

    private enum CodingKeys: String, CodingKey {
        case blockHash = "blockhash"
        case blockHeight = "blockheight"
        case blockTime = "blocktime"
        case confirmations
        case time
        case txid
        case inputs = "vin"
        case outputs = "vout"
    }
}

struct Input: Codable {

    let address: String
    let index: Int64
    let txID: String
    let value: Decimal
    let satoshi: Int64

    private enum CodingKeys: String, CodingKey {
        case address = "addr"
        case index = "n"
        case txID = "txid"
        case value = "value"
        case satoshi = "valueSat"
    }
}

struct Output: Codable {

    let index: Int64
    let scriptPubKey: ScriptPubKey
    let value: Decimal

    struct ScriptPubKey: Codable {
        let addresses: [String]
        let type: String
    }

    private enum CodingKeys: String, CodingKey {
        case index = "n"
        case scriptPubKey
        case value
    }
}

extension Output {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        index = try container.decode(Int64.self, forKey: .index)
        scriptPubKey = try container.decode(ScriptPubKey.self, forKey: .scriptPubKey)

        guard let decimalValue = Decimal(string: try container.decode(String.self, forKey: .value)) else {
            throw DecodingError.typeMismatch(
                Decimal.self,
                .init(codingPath: [CodingKeys.value], debugDescription: "Failed to convert String to Decimal")
            )
        }
        value = decimalValue
    }
}

enum Direction {
    case sent, received
}

extension CodableTx {
    func direction(addresses: [String]) -> Direction {
        let sending = inputs
            .map { input -> Bool in
                return addresses.contains(input.address)
            }
            .contains(true)

        return sending ? .sent : .received
    }

    func amount(addresses: [String]) -> Decimal {
        let amount = outputs
            .filter({ $0.scriptPubKey.addresses
                // [Bool] : 各txoutが自分のアドレス宛どうかの配列
                .map { addresses.contains($0) }
                // [Bool] : receiveの場合は自分宛のもののみTrue, sentの場合は相手宛のもののみTrueの配列
                .contains(direction(addresses: addresses) == .received)
            })
            .map { $0.value }
            .reduce(0, +)

        return amount
    }
}
