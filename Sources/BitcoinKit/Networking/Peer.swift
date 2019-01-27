//
//  Peer.swift
//
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 BitcoinKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Network

class Peer {
    private let connection: NWConnection
    private let concurrentConnectionQueue = DispatchQueue(label: "com.BitcoinKit.connectionQueue", attributes: .concurrent)
    private let network: Network
    private let host: String
    private let address: String?

    init(host: String, network: Network) {
        self.host = host
        self.network = network
        self.address = nil
        connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: UInt16(network.port))!, using: .tcp)
    }

    func connect() {
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                self.log("Connection ready")
            case .waiting(let error):
                self.log("Connection waiting: \(error)")
            case .failed(let error):
                self.log("Connection failed: \(error)")
            default:
                break
            }
        }
        connection.start(queue: concurrentConnectionQueue)
    }

    private func log(_ message: String) {
        print("\(String(describing: address ?? "")): \(message)")
    }
}
