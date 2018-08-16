//
//  BlockChain.swift
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

    public func calculateBalance(address: Address) throws -> Int64 {
        return try blockStore.calculateBalance(address: address)
    }

    public func latestBlockHash() -> Data {
        var latestBlockHash: Data?
        do {
            latestBlockHash = try blockStore.latestBlockHash()
        } catch {}
        return latestBlockHash ?? network.checkpoints.last!.hash
    }
}
