//
//  Messages.swift
//  BitcoinKit
//
//  Created by Kishikawa Katsumi on 2018/01/30.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import Foundation

// When a node creates an outgoing connection, it will immediately advertise its version.
// The remote node will respond with its version. No further communication is possible until both peers have exchanged their version.
public struct VersionMessage {
    // Identifies protocol version being used by the node
    public let version: Int32
    // bitfield of features to be enabled for this connection
    public let services: UInt64
    // standard UNIX timestamp in seconds
    public let timestamp: Int64
    // The network address of the node receiving this message
    public let yourAddress: NetworkAddress
    /* Fields below require version ≥ 106 */
    // The network address of the node emitting this message
    public let myAddress: NetworkAddress?
    // Node random nonce, randomly generated every time a version packet is sent. This nonce is used to detect connections to self.
    public let nonce: UInt64?
    // User Agent (0x00 if string is 0 bytes long)
    public let userAgent: VarString?
    // The last block received by the emitting node
    public let startHeight: Int32?
    /* Fields below require version ≥ 70001 */
    // Whether the remote peer should announce relayed transactions or not, see BIP 0037
    public let relay: Bool?

    public func serialized() -> Data {
        var data = Data()
        data += version.littleEndian
        data += services.littleEndian
        data += timestamp.littleEndian
        data += yourAddress.serialized()
        data += myAddress?.serialized() ?? Data(count: 26)
        data += nonce?.littleEndian ?? UInt64(0)
        data += userAgent?.serialized() ?? Data([UInt8(0x00)])
        data += startHeight?.littleEndian ?? Int32(0)
        data += relay ?? false
        return data
    }

    public static func deserialize(_ data: Data) -> VersionMessage {
        let byteStream = ByteStream(data)

        let version = byteStream.read(Int32.self)
        let services = byteStream.read(UInt64.self)
        let timestamp = byteStream.read(Int64.self)
        let yourAddress = NetworkAddress.deserialize(byteStream)
        guard byteStream.availableBytes > 0 else {
            return VersionMessage(version: version, services: services, timestamp: timestamp, yourAddress: yourAddress, myAddress: nil, nonce: nil, userAgent: nil, startHeight: nil, relay: nil)
        }
        let myAddress = NetworkAddress.deserialize(byteStream)
        let nonce = byteStream.read(UInt64.self)
        let userAgent = byteStream.read(VarString.self)
        let startHeight = byteStream.read(Int32.self)
        guard byteStream.availableBytes > 0 else {
            return VersionMessage(version: version, services: services, timestamp: timestamp, yourAddress: yourAddress, myAddress: myAddress, nonce: nonce, userAgent: userAgent, startHeight: startHeight, relay: nil)
        }
        let relay = byteStream.read(Bool.self)

        return VersionMessage(version: version, services: services, timestamp: timestamp, yourAddress: yourAddress, myAddress: myAddress, nonce: nonce, userAgent: userAgent, startHeight: startHeight, relay: relay)
    }
}


/// The verack message is sent in reply to version.
/// This message consists of only a message header with the command string "verack".
public struct VerackMessage {
    public func serialized() -> Data {
        return Data()
    }
}

/// Provide information on known nodes of the network. Non-advertised nodes should be forgotten after typically 3 hours
public struct AddressMessage {
    /// Number of address entries (max: 1000)
    public let count: VarInt
    /// Address of other nodes on the network. version < 209 will only read the first one.
    /// The uint32_t is a timestamp (see note below).
    public let addressList: [NetworkAddress]

    public static func deserialize(_ data: Data) -> AddressMessage {
        let byteStream = ByteStream(data)
        let count = byteStream.read(VarInt.self)
        var addressList = [NetworkAddress]()
        for _ in 0..<count.underlyingValue {
            _ = byteStream.read(UInt32.self) // Timestamp
            addressList.append(NetworkAddress.deserialize(byteStream))
        }
        return AddressMessage(count: count, addressList: addressList)
    }
}

/// Allows a node to advertise its knowledge of one or more objects. It can be received unsolicited, or in reply to getblocks.
public struct InventoryMessage {
    /// Number of inventory entries
    public let count: VarInt
    /// Inventory vectors
    public let inventoryItems: [InventoryItem]

    public func serialized() -> Data {
        var data = Data()
        data += count.serialized()
        data += inventoryItems.flatMap { $0.serialized() }
        return data
    }

    public static func deserialize(_ data: Data) -> InventoryMessage {
        let byteStream = ByteStream(data)
        let count = byteStream.read(VarInt.self)
        var items = [InventoryItem]()
        for _ in 0..<Int(count.underlyingValue) {
            items.append(InventoryItem.deserialize(byteStream))
        }
        return InventoryMessage(count: count, inventoryItems: items)
    }
}

public struct InventoryItem {
    /// Identifies the object type linked to this inventory
    public let type: Int32
    /// Hash of the object
    public let hash: Data

    public func serialized() -> Data {
        var data = Data()
        data += type
        data += hash
        return data
    }

    static func deserialize(_ byteStream: ByteStream) -> InventoryItem {
        let type = byteStream.read(Int32.self)
        let hash = byteStream.read(Data.self, count: 32)
        return InventoryItem(type: type, hash: hash)
    }

    public var objectType: ObjectType {
        switch type {
        case 0:
            return .error
        case 1:
            return .transactionMessage
        case 2:
            return .blockMessage
        case 3:
            return .filteredBlockMessage
        case 4:
            return .compactBlockMessage
        default:
            return .unknown
        }
    }

    public enum ObjectType : Int32 {
        /// Any data of with this number may be ignored
        case error = 0
        /// Hash is related to a transaction
        case transactionMessage = 1
        /// Hash is related to a data block
        case blockMessage = 2
        /// Hash of a block header; identical to MSG_BLOCK. Only to be used in getdata message.
        /// Indicates the reply should be a merkleblock message rather than a block message;
        /// this only works if a bloom filter has been set.
        case filteredBlockMessage = 3
        /// Hash of a block header; identical to MSG_BLOCK. Only to be used in getdata message.
        /// Indicates the reply should be a cmpctblock message. See BIP 152 for more info.
        case compactBlockMessage = 4
        case unknown
    }
}

/// getdata is used in response to inv, to retrieve the content of a specific object,
/// and is usually sent after receiving an inv packet, after filtering known elements.
/// It can be used to retrieve transactions, but only if they are in the memory pool or
/// relay set - arbitrary access to transactions in the chain is not allowed to avoid
/// having clients start to depend on nodes having full transaction indexes (which modern nodes do not).
public struct GetDataMessage {
    /// Number of inventory entries
    public let count: VarInt
    /// Inventory vectors
    public let inventoryItems: [InventoryItem]

    public func serialized() -> Data {
        var data = Data()
        data += count.serialized()
        data += inventoryItems.flatMap { $0.serialized() }
        return data
    }

    public static func deserialize(_ data: Data) -> GetDataMessage {
        let byteStream = ByteStream(data)
        let count = byteStream.read(VarInt.self).underlyingValue
        var items = [InventoryItem]()
        for _ in 0..<count {
            let type = byteStream.read(Int32.self)
            let hash = byteStream.read(Data.self, count: 32)
            let item = InventoryItem(type: type, hash: hash)
            items.append(item)
        }
        return GetDataMessage(count: VarInt(count), inventoryItems: items)
    }
}

/// The ping message is sent primarily to confirm that the TCP/IP connection is still valid.
/// An error in transmission is presumed to be a closed connection and the address is removed as a current peer.
public struct PingMessage {
    /// random nonce
    public let nonce: UInt64

    public static func deserialize(_ data: Data) -> PingMessage {
        let byteStream = ByteStream(data)
        let nonce = byteStream.read(UInt64.self)
        return PingMessage(nonce: nonce)
    }
}

/// The pong message is sent in response to a ping message.
/// In modern protocol versions, a pong response is generated using a nonce included in the ping.
public struct PongMessage {
    /// nonce from ping
    public let nonce: UInt64

    public func serialized() -> Data {
        var data = Data()
        data += nonce
        return data
    }
}

/// The reject message is sent when messages are rejected.
public struct RejectMessage {
    /// type of message rejected
    public let message: VarString
    /// code relating to rejected message
    /// 0x01  REJECT_MALFORMED
    /// 0x10  REJECT_INVALID
    /// 0x11  REJECT_OBSOLETE
    /// 0x12  REJECT_DUPLICATE
    /// 0x40  REJECT_NONSTANDARD
    /// 0x41  REJECT_DUST
    /// 0x42  REJECT_INSUFFICIENTFEE
    /// 0x43  REJECT_CHECKPOINT
    public let ccode: UInt8
    /// text version of reason for rejection
    public let reason: VarString
    /// Optional extra data provided by some errors.
    /// Currently, all errors which provide this field fill it with the TXID or
    /// block header hash of the object being rejected, so the field is 32 bytes.
    public let data: Data

    public static func deserialize(_ data: Data) -> RejectMessage {
        let byteStream = ByteStream(data)
        let message = byteStream.read(VarString.self)
        let ccode = byteStream.read(UInt8.self)
        let reason = byteStream.read(VarString.self)
        return RejectMessage(message: message, ccode: ccode, reason: reason, data: Data())
    }
}

public struct FilterLoadMessage {
    /// The filter itself is simply a bit field of arbitrary byte-aligned size. The maximum size is 36,000 bytes.
    public let filter: Data
    /// The number of hash functions to use in this filter. The maximum value allowed in this field is 50.
    public let nHashFuncs: UInt32
    /// A random value to add to the seed value in the hash function used by the bloom filter.
    public let nTweak: UInt32
    /// A set of flags that control how matched items are added to the filter.
    public let nFlags: UInt8

    public func serialized() -> Data {
        var data = Data()
        data += VarInt(filter.count).serialized()
        data += filter
        data += nHashFuncs
        data += nTweak
        data += nFlags
        return data
    }
}

public struct GetBlocksMessage {
    /// the protocol version
    public let version: UInt32
    /// number of block locator hash entries
    public let hashCount: VarInt
    /// block locator object; newest back to genesis block (dense to start, but then sparse)
    public let blockLocatorHashes: Data
    /// hash of the last desired block; set to zero to get as many blocks as possible (500)
    public let hashStop: Data

    public func serialized() -> Data {
        var data = Data()
        data += version
        data += hashCount.serialized()
        data += blockLocatorHashes
        data += hashStop
        return data
    }
}

public struct BlockMessage {
    /// Block version information (note, this is signed)
    public let version: Int32
    /// The hash value of the previous block this particular block references
    public let prevBlock: Data
    /// The reference to a Merkle tree collection which is a hash of all transactions related to this block
    public let merkleRoot: Data
    /// A Unix timestamp recording when this block was created (Currently limited to dates before the year 2106!)
    public let timestamp: UInt32
    /// The calculated difficulty target being used for this block
    public let bits: UInt32
    /// The nonce used to generate this block… to allow variations of the header and compute different hashes
    public let nonce: UInt32
    /// Number of transaction entries
    public let transactionCount: VarInt
    /// Block transactions, in format of "tx" command
    public let transactions: [Transaction]

    public func serialized() -> Data {
        var data = Data()
        data += version
        data += prevBlock
        data += merkleRoot
        data += timestamp
        data += bits
        data += nonce
        data += transactionCount.serialized()
        for transaction in transactions {
            data += transaction.serialized()
        }
        return data
    }

    public static func deserialize(_ data: Data) -> BlockMessage {
        let byteStream = ByteStream(data)
        let version = byteStream.read(Int32.self)
        let prevBlock = byteStream.read(Data.self, count: 32)
        let merkleRoot = byteStream.read(Data.self, count: 32)
        let timestamp = byteStream.read(UInt32.self)
        let bits = byteStream.read(UInt32.self)
        let nonce = byteStream.read(UInt32.self)
        let transactionCount = byteStream.read(VarInt.self)
        var transactions = [Transaction]()
        for _ in 0..<transactionCount.underlyingValue {
            transactions.append(Transaction.deserialize(byteStream))
        }
        return BlockMessage(version: version, prevBlock: prevBlock, merkleRoot: merkleRoot, timestamp: timestamp, bits: bits, nonce: nonce, transactionCount: transactionCount, transactions: transactions)
    }
}

public struct MerkleBlockMessage {
    /// Block version information, based upon the software version creating this block (note, this is signed)
    public let version: Int32
    /// The hash value of the previous block this particular block references
    public let prevBlock: Data
    /// The reference to a Merkle tree collection which is a hash of all transactions related to this block
    public let merkleRoot: Data
    /// A timestamp recording when this block was created (Limited to 2106!)
    public let timestamp: UInt32
    /// The calculated difficulty target being used for this block
    public let bits: UInt32
    /// The nonce used to generate this block… to allow variations of the header and compute different hashes
    public let nonce: UInt32
    /// Number of transactions in the block (including unmatched ones)
    public let totalTransactions: UInt32
    /// hashes in depth-first order (including standard varint size prefix)
    public let numberOfHashes: VarInt
    public let hashes: [Data]
    /// flag bits, packed per 8 in a byte, least significant bit first (including standard varint size prefix)
    public let numberOfFlags: VarInt
    public let flags: [UInt8]

    public func serialized() -> Data {
        var data = Data()
        data += version
        data += prevBlock
        data += merkleRoot
        data += timestamp
        data += bits
        data += nonce
        data += totalTransactions
        data += numberOfHashes.serialized()
        data += hashes.flatMap { $0 }
        data += numberOfFlags.serialized()
        data += flags
        return data
    }

    public static func deserialize(_ data: Data) -> MerkleBlockMessage {
        let byteStream = ByteStream(data)
        let version = byteStream.read(Int32.self)
        let prevBlock = byteStream.read(Data.self, count: 32)
        let merkleRoot = byteStream.read(Data.self, count: 32)
        let timestamp = byteStream.read(UInt32.self)
        let bits = byteStream.read(UInt32.self)
        let nonce = byteStream.read(UInt32.self)
        let totalTransactions = byteStream.read(UInt32.self)
        let numberOfHashes = byteStream.read(VarInt.self)
        var hashes = [Data]()
        for _ in 0..<numberOfHashes.underlyingValue {
            hashes.append(byteStream.read(Data.self, count: 32))
        }
        let numberOfFlags = byteStream.read(VarInt.self)
        var flags = [UInt8]()
        for _ in 0..<numberOfFlags.underlyingValue {
            flags.append(byteStream.read(UInt8.self))
        }
        return MerkleBlockMessage(version: version, prevBlock: prevBlock, merkleRoot: merkleRoot, timestamp: timestamp, bits: bits, nonce: nonce, totalTransactions: totalTransactions, numberOfHashes: numberOfHashes, hashes: hashes, numberOfFlags: numberOfFlags, flags: flags)
    }
}

class ByteStream {
    let data: Data
    private var offset = 0

    var availableBytes: Int {
        return data.count - offset
    }

    init(_ data: Data) {
        self.data = data
    }

    func read<T>(_ type: T.Type) -> T {
        let size = MemoryLayout<T>.size
        let value = data[offset..<(offset + size)].to(type: type)
        offset += size
        return value
    }

    func read(_ type: VarInt.Type) -> VarInt {
        let len = data[offset..<(offset + 1)].to(type: UInt8.self)
        let length: UInt64
        switch len {
        case 0...252:
            length = UInt64(len)
            offset += 1
        case 0xfd:
            offset += 1
            length = UInt64(data[offset..<(offset + 2)].to(type: UInt16.self))
            offset += 2
        case 0xfe:
            offset += 1
            length = UInt64(data[offset..<(offset + 4)].to(type: UInt32.self))
            offset += 4
        case 0xff:
            offset += 1
            length = UInt64(data[offset..<(offset + 8)].to(type: UInt64.self))
            offset += 8
        default:
            offset += 1
            length = UInt64(data[offset..<(offset + 8)].to(type: UInt64.self))
            offset += 8
        }
        return VarInt(length)
    }

    func read(_ type: VarString.Type) -> VarString {
        let length = read(VarInt.self).underlyingValue
        let size = Int(length)
        let value = data[offset..<(offset + size)].to(type: String.self)
        offset += size
        return VarString(value)
    }

    func read(_ type: Data.Type, count: Int) -> Data {
        let value = data[offset..<(offset + count)]
        offset += count
        return Data(value)
    }
}
