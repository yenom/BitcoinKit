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
        let urlString = baseUrl + "rawtransactions/sendRawTransaction/\(rawtx)"
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                print("response is nil.")
                completion?(nil)
                return
            }
            guard let response = String(bytes: data, encoding: .utf8) else {
                print("broadcast response cannot be decoded.")
                return
            }

            completion?(response)
        }
        task.resume()
    }
}

// MARK: - GET Unspent Transaction Outputs
private struct BitcoinComTxBroadcastResponse: Codable {
    let hex: String
}
