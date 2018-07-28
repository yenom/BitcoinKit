//
//  PeerGroup.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/31.
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 Shun Usami
//  Copyright © 2018 BitcoinCashKit developers
//  Licensed under the Apache License, Version 2.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  This file has been modified by the BitcoinCashKit developers for the BitcoinCashKit project.
//  The original file was from the bitcoinj project (https://github.com/kishikawakatsumi/BitcoinKit).
//

import Foundation

public class PeerGroup: PeerDelegate {
    public let blockChain: BlockChain
    public let maxConnections: Int

    public weak var delegate: PeerGroupDelegate?

    var peers = [String: Peer]()

    private var publicKeys = [Data]()
    private var transactions = [Transaction]()

    public init(blockChain: BlockChain, maxConnections: Int = 1) {
        self.blockChain = blockChain
        self.maxConnections = maxConnections
    }

    public func start() {
        let network = blockChain.network
        for _ in peers.count..<maxConnections {
            let peer = Peer(network: network)
            peer.delegate = self
            peer.connect()

            peers[peer.host] = peer
        }

        delegate?.peerGroupDidStart(self)
    }

    public func stop() {
        for peer in peers.values {
            peer.delegate = nil
            peer.disconnect()
        }
        peers.removeAll()

        delegate?.peerGroupDidStop(self)
    }

    // TODO: public key hashじゃなくて良いのか？
    public func addPublickey(publicKey: Data) {
        publicKeys.append(publicKey)
    }

    // TODO: 送るpeerは一つじゃなくて全部に送る?
    public func sendTransaction(transaction: Transaction) {
        if let peer = peers.values.first {
            peer.sendTransaction(transaction: transaction)
        } else {
            transactions.append(transaction)
            start()
        }
    }

    public func peerDidConnect(_ peer: Peer) {
        // TODO: isSyncingのpeerがあったらこのpeerとはstartSyncしなくてもいいのか・・・？
        if peers.filter({ $0.value.context.isSyncing }).isEmpty {
            let latestBlockHash = blockChain.latestBlockHash()
            peer.startSync(filters: publicKeys, latestBlockHash: latestBlockHash)
        }
        if !transactions.isEmpty {
            for transaction in transactions {
                peer.sendTransaction(transaction: transaction)
            }
        }
    }

    public func peerDidDisconnect(_ peer: Peer) {
        peers[peer.host] = nil
        start()
    }

    public func peer(_ peer: Peer, didReceiveVersionMessage message: VersionMessage) {
        if message.userAgent?.value.contains("Bitcoin ABC:0.16") == true {
            print("it's old version. Let's try to disconnect and connect to aother peer.")
            peer.disconnect()
        }
    }

    // TODO: Merkle Treeの検証はをすべきでは？
    public func peer(_ peer: Peer, didReceiveMerkleBlockMessage message: MerkleBlockMessage, hash: Data) {
        try! blockChain.addMerkleBlock(message, hash: hash)
    }

    public func peer(_ peer: Peer, didReceiveTransaction transaction: Transaction, hash: Data) {
        try! blockChain.addTransaction(transaction, hash: hash)
        delegate?.peerGroupDidReceiveTransaction(self)
    }
}

public protocol PeerGroupDelegate: class {
    func peerGroupDidStart(_ peerGroup: PeerGroup)
    func peerGroupDidStop(_ peerGroup: PeerGroup)
    func peerGroupDidReceiveTransaction(_ peerGroup: PeerGroup)
}

extension PeerGroupDelegate {
    public func peerGroupDidStart(_ peerGroup: PeerGroup) {}
    public func peerGroupDidStop(_ peerGroup: PeerGroup) {}
    public func peerGroupDidReceiveTransaction(_ peerGroup: PeerGroup) {}
}
