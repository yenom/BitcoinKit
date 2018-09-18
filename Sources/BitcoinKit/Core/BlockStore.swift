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

public protocol BlockStore {
    func addBlock(_ block: BlockMessage, hash: Data) throws
    func addMerkleBlock(_ merkleBlock: MerkleBlockMessage, hash: Data) throws
    func addTransaction(_ transaction: Transaction, hash: Data) throws
    func calculateBalance(address: Address) throws -> Int64
    func latestBlockHash() throws -> Data?
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)

public class SQLiteBlockStore: BlockStore {
    public static func `default`() throws -> SQLiteBlockStore {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return try SQLiteBlockStore(file: cachesDir.appendingPathComponent("blockchain.sqlite"))
    }

    let network: Network

    private var database: OpaquePointer?
    private var statements = [String: OpaquePointer]()

    public init(file: URL, network: Network = .testnet) throws {
        self.network = network

        try execute { sqlite3_open(file.path, &database) }
        try execute { sqlite3_exec(database,
                               """
                               PRAGMA foreign_keys = ON;
                               CREATE TABLE IF NOT EXISTS block (
                                   id BLOB NOT NULL PRIMARY KEY,
                                   version INTEGER NOT NULL,
                                   prev_block BLOB NOT NULL,
                                   merkle_root BLOB NOT NULL,
                                   timestamp INTEGER NOT NULL,
                                   bits INTEGER NOT NULL,
                                   nonce INTEGER NOT NULL,
                                   txn_count INTEGER NOT NULL
                               );
                               CREATE TABLE IF NOT EXISTS merkleblock (
                                   id BLOB NOT NULL PRIMARY KEY,
                                   version INTEGER NOT NULL,
                                   prev_block BLOB NOT NULL,
                                   merkle_root BLOB NOT NULL,
                                   timestamp INTEGER NOT NULL,
                                   bits INTEGER NOT NULL,
                                   nonce INTEGER NOT NULL,
                                   total_transactions INTEGER NOT NULL,
                                   hash_count INTEGER NOT NULL,
                                   hashes BLOB NOT NULL,
                                   flag_count INTEGER NOT NULL,
                                   flags BLOB NOT NULL
                               );
                               CREATE TABLE IF NOT EXISTS tx (
                                   id BLOB NOT NULL PRIMARY KEY,
                                   version INTEGER NOT NULL,
                                   flag INTEGER NOT NULL,
                                   tx_in_count INTEGER NOT NULL,
                                   tx_out_count INTEGER NOT NULL,
                                   lock_time INTEGER NOT NULL
                               );
                               CREATE TABLE IF NOT EXISTS txin (
                                   script_length INTEGER NOT NULL,
                                   signature_script BLOB NOT NULL,
                                   sequence INTEGER NOT NULL,
                                   tx_id BLOB NOT NULL,
                                   txout_id BLOB NOT NULL,
                                   FOREIGN KEY(tx_id) REFERENCES tx(id)
                               );
                               CREATE TABLE IF NOT EXISTS txout (
                                   out_index INTEGER NOT NULL,
                                   value INTEGER NOT NULL,
                                   pk_script_length INTEGER NOT NULL,
                                   pk_script BLOB NOT NULL,
                                   tx_id BLOB NOT NULL,
                                   address_id TEXT,
                                   FOREIGN KEY(tx_id) REFERENCES tx(id)
                               );
                               CREATE VIEW IF NOT EXISTS view_tx AS
                                  SELECT tx.id, txout.address_id, txout.out_index, txout.value, txin.txout_id from tx
                                  LEFT JOIN txout on id = txout.tx_id
                                  LEFT JOIN txin on id = txin.txout_id;
                               CREATE VIEW IF NOT EXISTS view_utxo AS
                                  SELECT tx.id, txout.address_id, txout.out_index, txout.value, txin.txout_id from tx
                                  LEFT JOIN txout on id = txout.tx_id
                                  LEFT JOIN txin on id = txin.txout_id
                                  WHERE txout_id IS NULL;
                               """,
                               nil,
                               nil,
                               nil) }

        statements["addBlock"] = try {
            var statement: OpaquePointer?
            try execute { sqlite3_prepare_v2(database,
                                             """
                                             REPLACE INTO block
                                                 (id, version, prev_block, merkle_root, timestamp, bits, nonce, txn_count)
                                                 VALUES
                                                 (?,  ?,       ?,          ?,           ?,         ?,    ?,     ?);
                                             """,
                                             -1,
                                             &statement,
                                             nil) }
            return statement
        }()
        statements["addMerkleBlock"] = try {
            var statement: OpaquePointer?
            try execute { sqlite3_prepare_v2(database,
                                             """
                                             REPLACE INTO merkleblock
                                                 (id, version, prev_block, merkle_root, timestamp, bits, nonce, total_transactions, hash_count, hashes, flag_count, flags)
                                                 VALUES
                                                 (?,  ?,       ?,          ?,           ?,         ?,    ?,     ?,                  ?,          ?,      ?,          ?);
                                             """,
                                             -1,
                                             &statement,
                                             nil) }
            return statement
        }()
        statements["addTransaction"] = try {
            var statement: OpaquePointer?
            try execute { sqlite3_prepare_v2(database,
                                             """
                                             REPLACE INTO tx
                                                 (id, version, flag, tx_in_count, tx_out_count, lock_time)
                                                 VALUES
                                                 (?,  ?,       ?,    ?,           ?,            ?);
                                             """,
                                             -1,
                                             &statement,
                                             nil) }
            return statement
        }()
        statements["addTransactionInput"] = try {
            var statement: OpaquePointer?
            try execute { sqlite3_prepare_v2(database,
                                             """
                                             INSERT INTO txin
                                                 (script_length, signature_script, sequence, tx_id, txout_id)
                                                 VALUES
                                                 (?,             ?,                ?,        ?,     ?);
                                             """,
                                             -1,
                                             &statement,
                                             nil) }
            return statement
        }()
        statements["addTransactionOutput"] = try {
            var statement: OpaquePointer?
            try execute { sqlite3_prepare_v2(database,
                                             """
                                             INSERT INTO txout
                                                 (out_index, value, pk_script_length, pk_script, tx_id, address_id)
                                                 VALUES
                                                 (?, ?,     ?,                ?,         ?,     ?);
                                             """,
                                             -1,
                                             &statement,
                                             nil) }
            return statement
        }()
        statements["deleteTransactionInput"] = try {
            var statement: OpaquePointer?
            try execute { sqlite3_prepare_v2(database,
                                             """
                                             DELETE FROM txin WHERE tx_id = ?;
                                             """,
                                             -1,
                                             &statement,
                                             nil) }
            return statement
        }()
        statements["deleteTransactionOutput"] = try {
            var statement: OpaquePointer?
            try execute { sqlite3_prepare_v2(database,
                                             """
                                             DELETE FROM txout WHERE tx_id = ?;
                                             """,
                                             -1,
                                             &statement,
                                             nil) }
            return statement
        }()
        statements["calculateBalance"] = try {
            var statement: OpaquePointer?
            try execute { sqlite3_prepare_v2(database,
                                             """
                                             SELECT value FROM view_utxo WHERE address_id == ?;
                                             """,
                                             -1,
                                             &statement,
                                             nil) }
            return statement
        }()
        statements["transactions"] = try {
            var statement: OpaquePointer?
            try execute { sqlite3_prepare_v2(database,
                                             """
                                             SELECT * FROM view_tx WHERE address_id == ?;
                                             """,
                                             -1,
                                             &statement,
                                             nil) }
            return statement
        }()
        statements["latestBlockHash"] = try {
            var statement: OpaquePointer?
            try execute { sqlite3_prepare_v2(database,
                                             """
                                             SELECT id FROM merkleblock ORDER BY timestamp DESC LIMIT 1;
                                             """,
                                             -1,
                                             &statement,
                                             nil) }
            return statement
        }()
        statements["unspentTransactions"] = try {
            var statement: OpaquePointer?
            try execute { sqlite3_prepare_v2(database,
                                             """
                                             SELECT * FROM view_utxo WHERE address_id == ?;
                                             """,
                                             -1,
                                             &statement,
                                             nil) }
            return statement
            }()
    }

    deinit {
        for statement in statements.values {
            try! execute { sqlite3_finalize(statement) }
        }
        try! execute { sqlite3_close(database) }
    }

    public func addBlock(_ block: BlockMessage, hash: Data) throws {
        let stmt = statements["addBlock"]

        try execute { hash.withUnsafeBytes { sqlite3_bind_blob(stmt, 1, $0, Int32(hash.count), SQLITE_TRANSIENT) } }
        try execute { sqlite3_bind_int64(stmt, 2, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: block.version))) }
        try execute { block.prevBlock.withUnsafeBytes { sqlite3_bind_blob(stmt, 3, $0, Int32(block.prevBlock.count), SQLITE_TRANSIENT) } }
        try execute { block.merkleRoot.withUnsafeBytes { sqlite3_bind_blob(stmt, 4, $0, Int32(block.merkleRoot.count), SQLITE_TRANSIENT) } }
        try execute { sqlite3_bind_int64(stmt, 5, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: block.timestamp))) }
        try execute { sqlite3_bind_int64(stmt, 6, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: block.bits))) }
        try execute { sqlite3_bind_int64(stmt, 7, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: block.nonce))) }
        try execute { sqlite3_bind_int64(stmt, 8, sqlite3_int64(bitPattern: block.transactionCount.underlyingValue)) }

        try executeUpdate { sqlite3_step(stmt) }
        try execute { sqlite3_reset(stmt) }
    }

    public func addMerkleBlock(_ merkleBlock: MerkleBlockMessage, hash: Data) throws {
        let stmt = statements["addMerkleBlock"]

        try execute { hash.withUnsafeBytes { sqlite3_bind_blob(stmt, 1, $0, Int32(hash.count), SQLITE_TRANSIENT) } }
        try execute { sqlite3_bind_int64(stmt, 2, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: merkleBlock.version))) }
        try execute { merkleBlock.prevBlock.withUnsafeBytes { sqlite3_bind_blob(stmt, 3, $0, Int32(merkleBlock.prevBlock.count), SQLITE_TRANSIENT) } }
        try execute { merkleBlock.merkleRoot.withUnsafeBytes { sqlite3_bind_blob(stmt, 4, $0, Int32(merkleBlock.merkleRoot.count), SQLITE_TRANSIENT) } }
        try execute { sqlite3_bind_int64(stmt, 5, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: merkleBlock.timestamp))) }
        try execute { sqlite3_bind_int64(stmt, 6, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: merkleBlock.bits))) }
        try execute { sqlite3_bind_int64(stmt, 7, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: merkleBlock.nonce))) }
        try execute { sqlite3_bind_int64(stmt, 8, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: merkleBlock.totalTransactions))) }
        try execute { sqlite3_bind_int64(stmt, 9, sqlite3_int64(bitPattern: merkleBlock.numberOfHashes.underlyingValue)) }
        let hashes = Data(merkleBlock.hashes.flatMap { $0 })
        try execute { hashes.withUnsafeBytes { sqlite3_bind_blob(stmt, 10, $0, Int32(hashes.count), SQLITE_TRANSIENT) } }
        try execute { sqlite3_bind_int64(stmt, 11, sqlite3_int64(bitPattern: merkleBlock.numberOfFlags.underlyingValue)) }
        let flags = Data(merkleBlock.flags)
        try execute { flags.withUnsafeBytes { sqlite3_bind_blob(stmt, 12, $0, Int32(flags.count), SQLITE_TRANSIENT) } }

        try executeUpdate { sqlite3_step(stmt) }
        try execute { sqlite3_reset(stmt) }
    }

    public func addTransaction(_ transaction: Transaction, hash: Data) throws {
        let stmt = statements["addTransaction"]

        try execute { hash.withUnsafeBytes { sqlite3_bind_blob(stmt, 1, $0, Int32(hash.count), SQLITE_TRANSIENT) } }
        try execute { sqlite3_bind_int64(stmt, 2, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: transaction.version))) }
        try execute { sqlite3_bind_int(stmt, 3, 0) } // Not supported 'flag' currently
        try execute { sqlite3_bind_int64(stmt, 4, sqlite3_int64(bitPattern: transaction.txInCount.underlyingValue)) }
        try execute { sqlite3_bind_int64(stmt, 5, sqlite3_int64(bitPattern: transaction.txOutCount.underlyingValue)) }
        try execute { sqlite3_bind_int64(stmt, 6, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: transaction.lockTime))) }

        try executeUpdate { sqlite3_step(stmt) }
        try execute { sqlite3_reset(stmt) }

        try deleteTransactionInput(txId: hash)
        for input in transaction.inputs {
            try addTransactionInput(input, txId: hash)
        }
        try deleteTransactionOutput(txId: hash)
        for (i, output) in transaction.outputs.enumerated() {
            try addTransactionOutput(index: i, output: output, txId: hash)
        }
    }

    public func addTransactionInput(_ input: TransactionInput, txId: Data) throws {
        let stmt = statements["addTransactionInput"]

        try execute { sqlite3_bind_int64(stmt, 1, sqlite3_int64(bitPattern: input.scriptLength.underlyingValue)) }
        try execute { input.signatureScript.withUnsafeBytes { sqlite3_bind_blob(stmt, 2, $0, Int32(input.signatureScript.count), SQLITE_TRANSIENT) } }
        try execute { sqlite3_bind_int64(stmt, 3, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: input.sequence))) }
        try execute { txId.withUnsafeBytes { sqlite3_bind_blob(stmt, 4, $0, Int32(txId.count), SQLITE_TRANSIENT) } }
        try execute { input.previousOutput.hash.withUnsafeBytes { sqlite3_bind_blob(stmt, 5, $0, Int32(input.previousOutput.hash.count), SQLITE_TRANSIENT) } }

        try executeUpdate { sqlite3_step(stmt) }
        try execute { sqlite3_reset(stmt) }
    }

    public func addTransactionOutput(index: Int, output: TransactionOutput, txId: Data) throws {
        let stmt = statements["addTransactionOutput"]

        try execute { sqlite3_bind_int64(stmt, 1, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: index))) }
        try execute { sqlite3_bind_int64(stmt, 2, sqlite3_int64(bitPattern: UInt64(truncatingIfNeeded: output.value))) }
        try execute { sqlite3_bind_int64(stmt, 3, sqlite3_int64(bitPattern: output.scriptLength.underlyingValue)) }
        try execute { output.lockingScript.withUnsafeBytes { sqlite3_bind_blob(stmt, 4, $0, Int32(output.lockingScript.count), SQLITE_TRANSIENT) } }
        try execute { txId.withUnsafeBytes { sqlite3_bind_blob(stmt, 5, $0, Int32(txId.count), SQLITE_TRANSIENT) } }
        if Script.isPublicKeyHashOut(output.lockingScript) {
            let pubKeyHash = Script.getPublicKeyHash(from: output.lockingScript)
            let address = publicKeyHashToAddress(Data([network.pubkeyhash]) + pubKeyHash)
            try execute { sqlite3_bind_text(stmt, 6, address, -1, nil) }
        }

        try executeUpdate { sqlite3_step(stmt) }
        try execute { sqlite3_reset(stmt) }
    }

    private func deleteTransactionInput(txId: Data) throws {
        let stmt = statements["deleteTransactionInput"]
        try execute { txId.withUnsafeBytes { sqlite3_bind_blob(stmt, 1, $0, Int32(txId.count), SQLITE_TRANSIENT) } }
        try executeUpdate { sqlite3_step(stmt) }
        try execute { sqlite3_reset(stmt) }
    }

    private func deleteTransactionOutput(txId: Data) throws {
        let stmt = statements["deleteTransactionOutput"]
        try execute { txId.withUnsafeBytes { sqlite3_bind_blob(stmt, 1, $0, Int32(txId.count), SQLITE_TRANSIENT) } }
        try executeUpdate { sqlite3_step(stmt) }
        try execute { sqlite3_reset(stmt) }
    }

    public func calculateBalance(address: Address) throws -> Int64 {
        let stmt = statements["calculateBalance"]
        try execute { sqlite3_bind_text(stmt, 1, address.base58, -1, SQLITE_TRANSIENT) }

        var balance: Int64 = 0
        while sqlite3_step(stmt) == SQLITE_ROW {
            let value = sqlite3_column_int64(stmt, 0)
            balance += value
        }

        try execute { sqlite3_reset(stmt) }

        return balance
    }

    public func transactions(address: Address) throws -> [Payment] {
        let stmt = statements["transactions"]
        try execute { sqlite3_bind_text(stmt, 1, address.base58, -1, SQLITE_TRANSIENT) }

        var payments = [Payment]()
        while sqlite3_step(stmt) == SQLITE_ROW {
            let txid = sqlite3_column_blob(stmt, 0)
            let address = sqlite3_column_text(stmt, 1)!
            let index = sqlite3_column_int64(stmt, 2)
            let value = sqlite3_column_int64(stmt, 3)
            payments.append(Payment(state: .received, index: index, amount: value, from: try! AddressFactory.create(String(cString: address)), to: try! AddressFactory.create(String(cString: address)), txid: Data(bytes: txid!, count: 32)))
        }

        try execute { sqlite3_reset(stmt) }

        return payments
    }

    public func unspentTransactions(address: Address) throws -> [Payment] {
        let stmt = statements["unspentTransactions"]
        try execute { sqlite3_bind_text(stmt, 1, address.base58, -1, SQLITE_TRANSIENT) }

        var payments = [Payment]()
        while sqlite3_step(stmt) == SQLITE_ROW {
            let txid = sqlite3_column_blob(stmt, 0)
            let address = sqlite3_column_text(stmt, 1)!
            let index = sqlite3_column_int64(stmt, 2)
            let value = sqlite3_column_int64(stmt, 3)
            payments.append(Payment(state: .received, index: index, amount: value, from: try! AddressFactory.create(String(cString: address)), to: try! AddressFactory.create(String(cString: address)), txid: Data(bytes: txid!, count: 32)))
        }

        try execute { sqlite3_reset(stmt) }

        return payments
    }

    public func latestBlockHash() throws -> Data? {
        let stmt = statements["latestBlockHash"]

        var hash: UnsafeRawPointer?
        if sqlite3_step(stmt) == SQLITE_ROW {
            hash = sqlite3_column_blob(stmt, 0)
        }
        if let hash = hash {
            return Data(bytes: hash, count: 32)
        } else {
            return nil
        }
    }

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
