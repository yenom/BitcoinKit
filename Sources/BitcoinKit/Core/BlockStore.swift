//
//  BlockStore.swift
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

// swiftlint:disable closure_end_indentation

import Foundation

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import SQLite3
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)

public struct Payment {
    public enum State {
        case sent
        case received
    }

    public let state: State
    public let index: Int64
    public let amount: Int64
    public let from: Address
    public let to: Address
    public let txid: Data
}

extension Payment: Equatable {
    static public func == (lhs: Payment, rhs: Payment) -> Bool {
        return lhs.txid == rhs.txid
    }
}

public protocol Database {
    // Block Header
    func addBlockHeader(_ blockHeader: Block, height: UInt32) throws
    func lastBlockHeader() throws -> Block?
}

public class SQLiteDatabase: Database {
    public static func `default`() throws -> SQLiteDatabase {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return try SQLiteDatabase(file: cachesDirectory.appendingPathComponent("blockchain.sqlite"))
    }

    private var database: OpaquePointer?
    public var statements = [String: OpaquePointer]()

    public init(file: URL) throws {
        try execute { sqlite3_open(file.path, &database) }
        try execute { sqlite3_exec(database,
                                    """
                                    CREATE TABLE IF NOT EXISTS block_headers (
                                        id BLOB NOT NULL PRIMARY KEY,
                                        version INTEGER NOT NULL,
                                        prev_block BLOB NOT NULL,
                                        merkle_root BLOB NOT NULL,
                                        timestamp INTEGER NOT NULL,
                                        bits INTEGER NOT NULL,
                                        nonce INTEGER NOT NULL,
                                        height INTEGER NOT NULL
                                    );
                                    """,
                                    nil,
                                    nil,
                                    nil)
        }
        statements["addBlockHeader"] = try {
            var statement: OpaquePointer?
            try execute { sqlite3_prepare_v2(database,
                                             """
                                             REPLACE INTO block_headers
                                                (id, version, prev_block, merkle_root, timestamp, bits, nonce, height)
                                                VALUES
                                                (?,     ?,        ?,            ?,         ?,      ?,     ?,      ?);
                                             """,
                                             -1,
                                             &statement,
                                             nil)
            }
            return statement
            }()
        statements["lastBlockHeader"] = try {
            var statement: OpaquePointer?
            try execute { sqlite3_prepare_v2(database,
                                             """
                                             SELECT * FROM block_headers ORDER BY height DESC LIMIT 1 ;
                                             """,
                                             -1,
                                             &statement,
                                             nil)
            }
            return statement
            }()
    }

    // MARK: Block Header

    public func addBlockHeader(_ blockHeader: Block, height: UInt32) throws {
        let statement = statements["addBlockHeader"]
        let hash = blockHeader.blockHash
        try execute { hash.withUnsafeBytes { sqlite3_bind_blob(statement, 1, $0, Int32(hash.count), SQLITE_TRANSIENT) } }
        try execute { sqlite3_bind_int64(statement, 2, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: blockHeader.version))) }
        try execute { blockHeader.prevBlock.withUnsafeBytes { sqlite3_bind_blob(statement, 3, $0, Int32(blockHeader.prevBlock.count), SQLITE_TRANSIENT) } }
        try execute { blockHeader.merkleRoot.withUnsafeBytes { sqlite3_bind_blob(statement, 4, $0, Int32(blockHeader.merkleRoot.count), SQLITE_TRANSIENT) } }
        try execute { sqlite3_bind_int64(statement, 5, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: blockHeader.timestamp))) }
        try execute { sqlite3_bind_int64(statement, 6, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: blockHeader.bits))) }
        try execute { sqlite3_bind_int64(statement, 7, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: blockHeader.nonce))) }
        try execute { sqlite3_bind_int64(statement, 8, sqlite3_int64(bitPattern: UInt64(height))) }

        try executeUpdate { sqlite3_step(statement) }
        try execute { sqlite3_reset(statement) }
    }

    public func lastBlockHeader() throws -> Block? {
        let statement = statements["lastBlockHeader"]
        var block: Block?
        if sqlite3_step(statement) == SQLITE_ROW {
            let version = Int32(sqlite3_column_int64(statement, 1))
            guard let prevBlock = sqlite3_column_blob(statement, 2) else {
                return nil
            }
            guard let merkleRoot = sqlite3_column_blob(statement, 3) else {
                return nil
            }
            let timestamp = UInt32(sqlite3_column_int64(statement, 4))
            let bits = UInt32(sqlite3_column_int64(statement, 5))
            let nonce = UInt32(sqlite3_column_int64(statement, 6))
            let height = UInt32(sqlite3_column_int64(statement, 7))
            block = Block(version: version, prevBlock: Data(bytes: prevBlock, count: 32), merkleRoot: Data(bytes: merkleRoot, count: 32), timestamp: timestamp, bits: bits, nonce: nonce, transactionCount: 0, transactions: [], height: height)
        }
        try execute { sqlite3_reset(statement) }
        return block
    }

    // MARK: others

    private func execute(_ closure: () -> Int32) throws {
        let code = closure()
        if code != SQLITE_OK {
            throw SQLiteError.error(code)
        }
    }

    private func executeUpdate(_ closure: () -> Int32) throws {
        let code = closure()
        if code != SQLITE_DONE {
            throw SQLiteError.error(code)
        }
    }
}

enum SQLiteError: Error {
    case error(Int32)
}

#endif
