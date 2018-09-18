//
//  BitcoinComService+TransactionBroadcaster.swift
//  BitcoinKit
//
//  Created by Shun Usami on 2018/09/18.
//  Copyright © 2018 BitcoinKit developers. All rights reserved.
//

import Foundation

extension BitcoinComService: TransactionBroadcaster {
    public func post(_ rawtx: String, completion: ((_ txid: String?) -> Void)?) {
        let url = URL(string: "https://rest.bitcoin.com/v1/rawtransactions/sendRawTransaction/\(rawtx)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                print("response is nil.")
                completion?(nil)
                return
            }
            guard let response = try? JSONDecoder().decode(BitcoinComTxBroadcastResponse.self, from: data) else {
                print("response cannot be decoded as BitcoinComTxBroadcastResponse.")
                completion?(nil)
                return
            }
            completion?(response.hex)
        }
        task.resume()
    }
}

// MARK: - GET Unspent Transaction Outputs
private struct BitcoinComTxBroadcastResponse: Codable {
    let hex: String
}
