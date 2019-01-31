//
//  PeerGroup.swift
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

public class PeerGroup {
    private let network: Network
    private let concurrentPeersQueue = DispatchQueue(label: "com.BitcoinKit.peersQueue", attributes: .concurrent)
    private let maxConnections: UInt
    private var unsafePeers = [Peer]()
    private var peers: [Peer] {
        var peersCopy: [Peer]!
        concurrentPeersQueue.sync {
            peersCopy = self.unsafePeers
        }
        return peersCopy
    }
    private var syncingPeer: Peer?
    private var lastBlock: Block?

    public init(network: Network, maxConnections: UInt) {
        self.network = network
        self.maxConnections = maxConnections
    }

    public func start() {
        for i in 0..<maxConnections {
            // TODO: select unique peer
            // TODO: select saved peers from db
            let dnsSeeds: [String] = network.dnsSeeds
            let peer = Peer(host: dnsSeeds[Int(arc4random_uniform(UInt32(dnsSeeds.count)))], network: network, identifier: i)
            peer.delegate = self
            addPeer(peer)
            peer.connect()
        }
    }

    private func addPeer(_ peer: Peer) {
        concurrentPeersQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                return
            }
            self.unsafePeers.append(peer)
        }
    }
}

extension PeerGroup: PeerDelegate {
    func peerDidHandShake(_ peer: Peer) {
        DispatchQueue.main.async {
            let remoteNodeHeight = peer.context.remoteNodeHeight
            if let syncingPeer = self.syncingPeer {
                guard remoteNodeHeight > syncingPeer.context.remoteNodeHeight else {
                    return
                }
            } else {
                self.syncingPeer = peer
            }
            if let lastBlock = self.lastBlock {
                guard remoteNodeHeight + 10 > lastBlock.height else {
                    peer.log("Node isn't synced: height is \(remoteNodeHeight)")
                    peer.disconnect()
                    return
                }
                guard remoteNodeHeight > lastBlock.height else {
                    // no need to get new block headers
                    return
                }
            }
            // start blockchain sync
            peer.sendGetHeadersMessage(blockHash: self.lastBlock?.blockHash ?? Data(count: 32))
        }
    }
}
