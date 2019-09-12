//
//  MerkleTree.swift
//
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

struct MerkleTree {
	enum MerkleError: Error {
		case noEnoughParent
		case noEnoughHash
		case duplicateHash // CVE-2012-2459
		case invalidNumberOfHashes
		case invalidNumberOfFlags
		case nullHash
	}

	static func buildMerkleRoot(numberOfHashes: UInt32, hashes: [Data], numberOfFlags: UInt32, flags: [UInt8], totalTransactions: UInt32) throws -> Data {
		if numberOfHashes != hashes.count {
			throw MerkleError.invalidNumberOfHashes
		}
		if flags.count < numberOfFlags / 8 {
			throw MerkleError.invalidNumberOfFlags
		}
		let parents: [Bool] = (0 ..< Int(numberOfFlags)).compactMap({
			return (flags[$0 / 8] & UInt8(1 << ($0 % 8))) != 0
		})
		let maxdepth: UInt = UInt(ceil_log2(totalTransactions))
		var hashIterator = hashes.makeIterator()
		var parentIterator = parents.makeIterator()
		let root = try buildPartialMerkleTree(hashIterator: &hashIterator, parentIterator: &parentIterator, depth: 0, maxdepth: maxdepth)
		guard let h = root.hash else { throw MerkleError.nullHash }
		return h
	}

	struct PartialMerkleTree {
		var hash: Data?
		// zero size if depth is maxdepth
		// leaf[0]: left, leaf[1]: right
		var leaf: [PartialMerkleTree] = []
		init(hash: Data, leafL: PartialMerkleTree, leafR: PartialMerkleTree) {
			self.hash = hash
			leaf.append(leafL)
			leaf.append(leafR)
		}
		init(hash: Data) {
			self.hash = hash
		}
	}

	private static func buildPartialMerkleTree(
		hashIterator: inout IndexingIterator<[Data]>,
		parentIterator: inout IndexingIterator<[Bool]>,
		depth: UInt, maxdepth: UInt) throws -> PartialMerkleTree {
		guard let parent = parentIterator.next() else { throw MerkleError.noEnoughParent }
		if !parent || maxdepth <= depth {
			// leaf
			guard let hash = hashIterator.next() else { throw MerkleError.noEnoughHash }
			return PartialMerkleTree(hash: hash)
		} else {
			// vertex
			let left: PartialMerkleTree = try buildPartialMerkleTree(hashIterator: &hashIterator, parentIterator: &parentIterator, depth: depth + 1, maxdepth: maxdepth)
			let right: PartialMerkleTree = try buildPartialMerkleTree(hashIterator: &hashIterator, parentIterator: &parentIterator, depth: depth + 1, maxdepth: maxdepth)
			if let h0 = left.hash, let h1 = right.hash {
				if h0 == h1 {
					// CVE-2012-2459
    				throw MerkleError.duplicateHash
				}
				let hash = Crypto.sha256sha256(h0 + h1)
				return PartialMerkleTree(hash: hash, leafL: left, leafR: right)
			} else {
				throw MerkleError.nullHash
			}
		}
	}
}
