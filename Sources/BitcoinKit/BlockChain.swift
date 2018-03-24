//
//  BlockChain.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/02/03.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

public class BlockChain {
    let network: Network
    let blockStore: BlockStore

    public init(network: Network, blockStore: BlockStore) {
        self.network = network
        self.blockStore = blockStore
    }

    public func addBlock(_ block: BlockMessage, hash: Data) throws {
        try blockStore.addBlock(block, hash: hash)
    }

    public func addMerkleBlock(_ merkleBlock: MerkleBlockMessage, hash: Data) throws {
        try blockStore.addMerkleBlock(merkleBlock, hash: hash)
    }

    public func addTransaction(_ transaction: Transaction, hash: Data) throws {
        try blockStore.addTransaction(transaction, hash: hash)
    }

    public func calculateBlance(address: Address) throws -> Int64 {
        return try blockStore.calculateBlance(address: address)
    }

    public func latestBlockHash() -> Data {
        var latestBlockHash: Data?
        do {
            latestBlockHash = try blockStore.latestBlockHash()
        } catch {}
        return latestBlockHash ?? network.checkpoints.last!.hash
    }
}
