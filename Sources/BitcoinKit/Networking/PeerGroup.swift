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
    private let database: Database
    private let network: Network
    private let maxConnections: UInt
    private var peers = [Peer]()
    private var syncingPeer: Peer?
    private var lastBlock: Block
    private var nextCheckpointIndex: Int = 0

    public init(database: Database, network: Network, maxConnections: UInt) {
        self.database = database
        self.network = network
        self.maxConnections = maxConnections
        lastBlock = network.genesisBlock
        print(lastBlock.blockHash.hex)
    }

    public func start() {
        for i in 0..<maxConnections {
            // TODO: select unique peer
            // TODO: select saved peers from db
            let dnsSeeds: [String] = network.dnsSeeds
            let peer = Peer(host: dnsSeeds[Int(arc4random_uniform(UInt32(dnsSeeds.count)))], network: network, identifier: i)
            peer.delegate = self
            peers.append(peer)
            peer.connect()
        }
    }
}

extension PeerGroup: PeerDelegate {
    func peerDidHandShake(_ peer: Peer) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            let remoteNodeHeight = peer.context.remoteNodeHeight
            if let syncingPeer = self.syncingPeer {
                guard remoteNodeHeight > syncingPeer.context.remoteNodeHeight else {
                    return
                }
            } else {
                self.syncingPeer = peer
            }
            let lastBlockHeight = self.lastBlock.height
            guard remoteNodeHeight + 10 > lastBlockHeight else {
                peer.log("Node isn't synced: height is \(remoteNodeHeight)")
                peer.disconnect()
                return
            }
            guard remoteNodeHeight > lastBlockHeight else {
                // no need to get new block headers
                return
            }
            // start blockchain sync
            // TODO: set block locator hash
            peer.sendGetHeadersMessage(blockHash: Data(self.lastBlock.blockHash.reversed()))
        }
    }

    func peer(_ peer: Peer, didReceiveBlockHeaders blockHeaders: [Block]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            // send GetHeadersMessage if necessary
            let lastBlock = self.lastBlock
            if peer.context.remoteNodeHeight > lastBlock.height + UInt32(blockHeaders.count) {
                guard let lastBlockHeader = blockHeaders.last else {
                    peer.log("Header message carries zero headers")
                    return
                }
                peer.log("Received block header height is \(lastBlock.height + UInt32(blockHeaders.count))")
                // TODO: set locator hash
                peer.sendGetHeadersMessage(blockHash: lastBlockHeader.blockHash)
            } else {
                // load bloom filter if we're done syncing
                peer.log("Sync done")
            }

            // save block header
            for blockHeader in blockHeaders {
                let blockHeight = lastBlock.height + 1
                let (nextCheckpointIndex, checkpoints) = (self.nextCheckpointIndex, self.network.checkpoints)
                if nextCheckpointIndex < checkpoints.count {
                    let nextCheckpoint = checkpoints[nextCheckpointIndex]
                    if blockHeight == nextCheckpoint.height {
                        guard blockHeader.blockHash == nextCheckpoint.hash else {
                            peer.log("block hash does not match the checkpoint, height: \(blockHeight), blockhash: \(Data(blockHeader.blockHash.reversed()).hex)")
                            peer.disconnect()
                            return
                        }
                        self.nextCheckpointIndex = nextCheckpointIndex + 1
                    }
                }
                if lastBlock.blockHash == blockHeader.prevBlock {
                    peer.log("Last block hash does not match the prev block.")
                    // TODO: handle re-org case
                    return
                }
                try! self.database.addBlockHeader(blockHeader, height: blockHeight)
                self.lastBlock = blockHeader
                self.lastBlock.height = blockHeight
            }
        }
    }
}
