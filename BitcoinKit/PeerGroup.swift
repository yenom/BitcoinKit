//
//  PeerGroup.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/31.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public class PeerGroup : PeerDelegate {
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
        for i in peers.count..<maxConnections {
            let peer = Peer(host: network.dnsSeeds[1], network: network)
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

    public func addPublickey(publicKey: Data) {
        publicKeys.append(publicKey)
    }

    public func sendTransaction(transaction: Transaction) {
        if let peer = peers.values.first {
            peer.sendTransaction(transaction: transaction)
        } else {
            transactions.append(transaction)
            start()
        }
    }

    public func peerDidConnect(_ peer: Peer) {
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

    public func peer(_ peer: Peer, didReceiveMerkleBlockMessage message: MerkleBlockMessage, hash: Data) {
        try! blockChain.addMerkleBlock(message, hash: hash)
    }

    public func peer(_ peer: Peer, didReceiveTransaction transaction: Transaction, hash: Data) {
        try! blockChain.addTransaction(transaction, hash: hash)
        delegate?.peerGroupDidReceiveTransaction(self)
    }
}

public protocol PeerGroupDelegate : class {
    func peerGroupDidStart(_ peerGroup: PeerGroup)
    func peerGroupDidStop(_ peerGroup: PeerGroup)
    func peerGroupDidReceiveTransaction(_ peerGroup: PeerGroup)
}

extension PeerGroupDelegate {
    public func peerGroupDidStart(_ peerGroup: PeerGroup) {}
    public func peerGroupDidStop(_ peerGroup: PeerGroup) {}
    public func peerGroupDidReceiveTransaction(_ peerGroup: PeerGroup) {}
}
