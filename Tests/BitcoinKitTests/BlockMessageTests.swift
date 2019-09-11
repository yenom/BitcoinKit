//
//  BlockMessageTests.swift
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

import XCTest
@testable import BitcoinKit

class BlockMessageTests: XCTestCase {
    fileprivate func loadRawBlock(named name: String) throws -> BlockMessage {
        let data: Data
        #if BitcoinKitXcode
        let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: "raw")!
        data = try Data(contentsOf: url)
        #else
        // find raw files if using Swift Package Manager:
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let fileURL = currentDirectoryURL
            .appendingPathComponent("TestResources", isDirectory: true)
            .appendingPathComponent(name)
            .appendingPathExtension("raw")
        data = try Data(contentsOf: fileURL)
        #endif

        return BlockMessage.deserialize(data)
    }

    func testComputeMerkleRoot() throws {
        let block1 = try loadRawBlock(named: "block1")
        XCTAssertEqual(block1.computeMerkleRoot(), block1.merkleRoot)

        let block413567 = try loadRawBlock(named: "block413567")
        XCTAssertEqual(block413567.computeMerkleRoot(), block413567.merkleRoot)
    }
    
}
