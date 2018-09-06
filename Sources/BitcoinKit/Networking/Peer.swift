//
//  Peer.swift
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

private let protocolVersion: Int32 = 70_015
private let bufferSize = 4096

public class Peer: NSObject, StreamDelegate {
    public let host: String
    public var port: UInt32 {
        return network.port
    }
    public let network: Network

    public weak var delegate: PeerDelegate?

    let context = Context()
    var latestBlockHash: Data

    class Context {
        var packets = Data()
        /// Transactions to be sent
        var transactions = [Data: Transaction]()

        var pingTime = Date()
        var estimatedHeight: Int32 = 0

        var sentVersion = false
        var sentVerack = false
        var gotVerack = false
        var sentGetAddr = false
        var sentFilterLoad = false
        var sentGetData = false
        var sentMemPool = false
        var sentGetBlocks = false

        var isSyncing = false
        var inventoryItems = [Data: InventoryItem]()
    }

    private var readStream: Unmanaged<CFReadStream>?
    private var writeStream: Unmanaged<CFWriteStream>?
    private var inputStream: InputStream!
    private var outputStream: OutputStream!

    public convenience init(network: Network = .testnet) {
        self.init(host: network.dnsSeeds[Int(arc4random_uniform(UInt32(network.dnsSeeds.count)))], network: network)
    }

    public init(host: String, network: Network = .testnet) {
        self.host = host
        self.network = network
        latestBlockHash = network.genesisBlock
    }

    deinit {
        disconnect()
    }

    public func connect() {
        log("connecting")

        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host as CFString, port, &readStream, &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()

        inputStream.delegate = self
        outputStream.delegate = self

        inputStream.schedule(in: .current, forMode: .commonModes)
        outputStream.schedule(in: .current, forMode: .commonModes)

        inputStream.open()
        outputStream.open()
    }

    public func disconnect() {
        guard readStream != nil && readStream != nil else {
            return
        }

        inputStream.delegate = nil
        outputStream.delegate = nil
        inputStream.remove(from: .current, forMode: .commonModes)
        outputStream.remove(from: .current, forMode: .commonModes)
        inputStream.close()
        outputStream.close()
        readStream = nil
        writeStream = nil

        log("disconnected")
        self.delegate?.peerDidDisconnect(self)
    }

    public func startSync(filters: [Data] = [], latestBlockHash: Data) {
        self.latestBlockHash = latestBlockHash
        context.isSyncing = true

        if !self.context.sentFilterLoad {
            sendFilterLoadMessage(filters: filters)
            self.context.sentFilterLoad = true
            if !self.context.sentMemPool {
                self.sendMemoryPoolMessage()
                self.context.sentMemPool = true
            }
        }
        self.sendGetBlocksMessage()
    }

    public func sendTransaction(transaction: Transaction) {
        sendTransactionInventory(transaction: transaction)
    }

    // swiftlint:disable:next cyclomatic_complexity
    public func stream(_ stream: Stream, handle eventCode: Stream.Event) {
        switch stream {
        case let stream as InputStream:
            switch eventCode {
            case .openCompleted:
                log("socket connected")
            case .hasBytesAvailable:
                readAvailableBytes(stream: stream)
            case .hasSpaceAvailable:
                break
            case .errorOccurred:
                log("socket error occurred")
                disconnect()
            case .endEncountered:
                log("socket closed")
                disconnect()
            default:
                break
            }
        case _ as OutputStream:
            switch eventCode {
            case .openCompleted:
                break
            case .hasBytesAvailable:
                break
            case .hasSpaceAvailable:
                if !context.sentVersion {
                    sendVersionMessage()
                    context.sentVersion = true
                }
            case .errorOccurred:
                log("socket error occurred")
                disconnect()
            case .endEncountered:
                log("socket closed")
                disconnect()
            default:
                break
            }
        default:
            break
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        while stream.hasBytesAvailable {
            let numberOfBytesRead = stream.read(buffer, maxLength: bufferSize)
            if numberOfBytesRead <= 0 {
                if stream.streamError != nil { break }
            } else {
                context.packets += Data(bytesNoCopy: buffer, count: numberOfBytesRead, deallocator: .none)
            }
        }
        while context.packets.count >= Message.minimumLength {
            guard let message = Message.deserialize(context.packets) else {
                return
            }
            autoreleasepool {
                context.packets = Data(context.packets.dropFirst(Message.minimumLength + Int(message.length)))
                switch message.command {
                case "version":
                    // When a node creates an outgoing connection, it will immediately advertise its version.
                    // The remote node will respond with its version. No further communication is possible until both peers have exchanged their version.
                    handleVersionMessage(payload: message.payload)
                case "verack":
                    // The verack message is sent in reply to version. This message consists of only a message header with the command string "verack".
                    handleVerackMessage(payload: message.payload)
                case "addr":
                    // Provide information on known nodes of the network. Non-advertised nodes should be forgotten after typically 3 hours
                    handleAddressMessage(payload: message.payload)
                case "inv":
                    // Allows a node to advertise its knowledge of one or more objects. It can be received unsolicited, or in reply to getblocks.
                    // Payload (maximum 50,000 entries, which is just over 1.8 megabytes):
                    handleInventoryMessage(payload: message.payload)
                case "getdata":
                    // getdata is used in response to inv, to retrieve the content of a specific object, and is usually sent after receiving an inv packet, after filtering known elements.
                    // It can be used to retrieve transactions, but only if they are in the memory pool or relay set - arbitrary access to transactions in the chain is not allowed to avoid having clients start to depend on nodes having full transaction indexes (which modern nodes do not).
                    // Payload (maximum 50,000 entries, which is just over 1.8 megabytes):
                    handleGetDataMessage(payload: message.payload)
                case "notfound":
                    // notfound is a response to a getdata, sent if any requested data items could not be relayed, for example, because the requested transaction was not in the memory pool or relay set.
                    break
                case "block":
                    // The block message is sent in response to a getdata message which requests transaction information from a block hash.
                    handleBlockMessage(payload: message.payload)
                case "tx":
                    // tx describes a bitcoin transaction, in reply to getdata
                    handleTransaction(payload: message.payload)
                case "ping":
                    // The ping message is sent primarily to confirm that the TCP/IP connection is still valid. An error in transmission is presumed to be a closed connection and the address is removed as a current peer.
                    handlePingMessage(payload: message.payload)
                case "merkleblock":
                    handleMerkleBlockMessage(payload: message.payload)
                case "reject":
                    // The reject message is sent when messages are rejected.
                    handleRejectMessage(payload: message.payload)
                default:
                    break
                }
            }
        }
    }

    private func sendMessage(_ message: Message) {
        log("sending \(message.command)")
        let data = message.serialized()
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
    }

    private func sendVersionMessage() {
        let version = VersionMessage(version: protocolVersion,
                                     services: 0x00,
                                     timestamp: Int64(Date().timeIntervalSince1970),
                                     yourAddress: NetworkAddress(services: 0x00,
                                                              address: "::ffff:127.0.0.1",
                                                              port: UInt16(port)),
                                     myAddress: NetworkAddress(services: 0x00,
                                                              address: "::ffff:127.0.0.1",
                                                              port: UInt16(port)),
                                     nonce: 0,
                                     userAgent: "/BitcoinKit:1.0.2/",
                                     startHeight: -1,
                                     relay: false)
        let payload = version.serialized()
        let checksum = Data(Crypto.sha256sha256(payload).prefix(4))

        let message = Message(magic: network.magic, command: "version", length: UInt32(payload.count), checksum: checksum, payload: payload)
        sendMessage(message)
    }

    private func sendVerackMessage() {
        let payload = Data()
        let checksum = Data(Crypto.sha256sha256(payload).prefix(4))
        let message = Message(magic: network.magic, command: "verack", length: UInt32(payload.count), checksum: checksum, payload: payload)
        sendMessage(message)
        context.pingTime = Date()
    }

    private func sendFilterLoadMessage(filters: [Data]) {
        guard !filters.isEmpty else { return }

        let nTweak = arc4random_uniform(UInt32.max)
        var filter = BloomFilter(elements: filters.count, falsePositiveRate: 0.000_05, randomNonce: nTweak)

        for f in filters {
            filter.insert(f)
        }

        let filterData = Data(filter.data)
        let filterLoad = FilterLoadMessage(filter: filterData, nHashFuncs: filter.nHashFuncs, nTweak: nTweak, nFlags: 0)

        let payload = filterLoad.serialized()
        let checksum = Data(Crypto.sha256sha256(payload).prefix(4))

        let message = Message(magic: network.magic, command: "filterload", length: UInt32(payload.count), checksum: checksum, payload: payload)
        sendMessage(message)
    }

    private func sendMemoryPoolMessage() {
        let payload = Data()
        let checksum = Data(Crypto.sha256sha256(payload).prefix(4))
        let message = Message(magic: network.magic, command: "mempool", length: UInt32(payload.count), checksum: checksum, payload: payload)
        sendMessage(message)
    }

    private func sendGetBlocksMessage() {
        let blockLocatorHash = latestBlockHash
        let getBlocks = GetBlocksMessage(version: UInt32(protocolVersion), hashCount: 1, blockLocatorHashes: blockLocatorHash, hashStop: Data(count: 32))

        let payload = getBlocks.serialized()
        let checksum = Data(Crypto.sha256sha256(payload).prefix(4))

        let message = Message(magic: network.magic, command: "getblocks", length: UInt32(payload.count), checksum: checksum, payload: payload)
        sendMessage(message)
    }

    private func sendGetDataMessage(message: InventoryMessage) {
        let payload = message.serialized()
        let checksum = Data(Crypto.sha256sha256(payload).prefix(4))

        let message = Message(magic: network.magic, command: "getdata", length: UInt32(payload.count), checksum: checksum, payload: payload)
        sendMessage(message)
    }

    private func sendTransactionInventory(transaction: Transaction) {
        let txId = Crypto.sha256sha256(transaction.serialized())
        context.transactions[txId] = transaction

        let inv = InventoryMessage(count: 1, inventoryItems: [InventoryItem(type: InventoryItem.ObjectType.transactionMessage.rawValue, hash: txId)])

        let payload = inv.serialized()
        let checksum = Data(Crypto.sha256sha256(payload).prefix(4))

        let message = Message(magic: network.magic, command: "inv", length: UInt32(payload.count), checksum: checksum, payload: payload)
        sendMessage(message)
    }

    private func handleVersionMessage(payload: Data) {
        let version = VersionMessage.deserialize(payload)
        context.estimatedHeight = version.startHeight ?? 0

        log("got version \(version.version), useragent: \(version.userAgent?.value ?? ""), services: \(ServiceFlags(rawValue: version.services))")
        delegate?.peer(self, didReceiveVersionMessage: version)

        if !context.sentVerack {
            sendVerackMessage()
            context.sentVerack = true
        }
    }

    private func handleVerackMessage(payload: Data) {
        log("got verack in \(String(format: "%g", Date().timeIntervalSince(context.pingTime)))s")
        context.gotVerack = true
        delegate?.peerDidConnect(self)
    }

    private func handleAddressMessage(payload: Data) {
        let address = AddressMessage.deserialize(payload)
        log("got addr with \(address.count) address(es)")
        delegate?.peer(self, didReceiveAddressMessage: address)
    }

    private func handleGetDataMessage(payload: Data) {
        let getData = GetDataMessage.deserialize(payload)
        log("got getdata with \(getData.count) item(s)")
        delegate?.peer(self, didReceiveGetDataMessage: getData)

        for item in getData.inventoryItems {
            switch item.objectType {
            case .error:
                break
            case .transactionMessage:
                // Send transaction
                if let transaction = context.transactions[item.hash] {
                    let payload = transaction.serialized()
                    let checksum = Data(Crypto.sha256sha256(payload).prefix(4))

                    let message = Message(magic: network.magic, command: "tx", length: UInt32(payload.count), checksum: checksum, payload: payload)
                    sendMessage(message)
                }
            case .blockMessage:
                break
            case .filteredBlockMessage:
                break
            case .compactBlockMessage:
                break
            case .unknown:
                break
            }
        }
    }

    private func handleInventoryMessage(payload: Data) {
        let inventory = InventoryMessage.deserialize(payload)
        log("got inv with \(inventory.count) item(s)")
        delegate?.peer(self, didReceiveInventoryMessage: inventory)

        // 1. filteredBlockMessageとtransactionsは受け取る
        let transactionItems: [InventoryItem] = inventory.inventoryItems.filter { $0.objectType == .transactionMessage }
        let blockItems: [InventoryItem] = inventory.inventoryItems
            .filter { $0.objectType == .blockMessage || $0.objectType == .filteredBlockMessage }
            .map { InventoryItem(type: InventoryItem.ObjectType.filteredBlockMessage.rawValue, hash: $0.hash) }
        let filterdItems: [InventoryItem] = transactionItems + blockItems

        guard !filterdItems.isEmpty else {
            return
        }
        sendGetDataMessage(message: InventoryMessage(count: VarInt(filterdItems.count), inventoryItems: filterdItems))
        for item in filterdItems {
            context.inventoryItems[Data(item.hash.reversed())] = item
        }
    }

    private func handleBlockMessage(payload: Data) {
        let block = BlockMessage.deserialize(payload)
        let blockHash = Data(Crypto.sha256sha256(payload.prefix(80)).reversed())
        delegate?.peer(self, didReceiveBlockMessage: block, hash: blockHash)

        context.inventoryItems[blockHash] = nil
        if context.inventoryItems.isEmpty {
            latestBlockHash = blockHash
            sendGetBlocksMessage()
        }
    }

    private func handleMerkleBlockMessage(payload: Data) {
        let merkleBlock = MerkleBlockMessage.deserialize(payload)
        let blockHash = Crypto.sha256sha256(payload.prefix(80))
        delegate?.peer(self, didReceiveMerkleBlockMessage: merkleBlock, hash: blockHash)

        context.inventoryItems[Data(blockHash.reversed())] = nil
        if context.inventoryItems.isEmpty {
            latestBlockHash = blockHash
            sendGetBlocksMessage()
        }
    }

    private func handleTransaction(payload: Data) {
        let transaction = Transaction.deserialize(payload)
        let txHash = Data(Crypto.sha256sha256(payload).reversed())
        log("got tx: \(txHash.hex)")
        delegate?.peer(self, didReceiveTransaction: transaction, hash: txHash)
    }

    private func handlePingMessage(payload: Data) {
        let ping = PingMessage.deserialize(payload)
        let pong = PongMessage(nonce: ping.nonce)
        log("got ping")

        let payload = pong.serialized()
        let checksum = Data(Crypto.sha256sha256(payload).prefix(4))

        let message = Message(magic: network.magic, command: "pong", length: UInt32(payload.count), checksum: checksum, payload: payload)
        sendMessage(message)
    }

    private func handleRejectMessage(payload: Data) {
        let reject = RejectMessage.deserialize(payload)

        log("rejected \(reject.message) code: 0x\(String(reject.ccode, radix: 16)) reason: \(reject.reason), data: \(reject.data.hex)")
        delegate?.peer(self, didReceiveRejectMessage: reject)
    }

    private func log(_ message: String) {
        print("\(host):\(port) \(message)")
    }
}

public protocol PeerDelegate: class {
    func peerDidConnect(_ peer: Peer)
    func peerDidDisconnect(_ peer: Peer)
    func peer(_ peer: Peer, didReceiveVersionMessage message: VersionMessage)
    func peer(_ peer: Peer, didReceiveAddressMessage message: AddressMessage)
    func peer(_ peer: Peer, didReceiveGetDataMessage message: GetDataMessage)
    func peer(_ peer: Peer, didReceiveInventoryMessage message: InventoryMessage)
    func peer(_ peer: Peer, didReceiveBlockMessage message: BlockMessage, hash: Data)
    func peer(_ peer: Peer, didReceiveMerkleBlockMessage message: MerkleBlockMessage, hash: Data)
    func peer(_ peer: Peer, didReceiveTransaction transaction: Transaction, hash: Data)
    func peer(_ peer: Peer, didReceiveRejectMessage message: RejectMessage)
}

extension PeerDelegate {
    public func peerDidConnect(_ peer: Peer) {}
    public func peerDidDisconnect(_ peer: Peer) {}
    public func peer(_ peer: Peer, didReceiveVersionMessage message: VersionMessage) {}
    public func peer(_ peer: Peer, didReceiveAddressMessage message: AddressMessage) {}
    public func peer(_ peer: Peer, didReceiveGetDataMessage message: GetDataMessage) {}
    public func peer(_ peer: Peer, didReceiveInventoryMessage message: InventoryMessage) {}
    public func peer(_ peer: Peer, didReceiveBlockMessage message: BlockMessage, hash: Data) {}
    public func peer(_ peer: Peer, didReceiveMerkleBlockMessage message: MerkleBlockMessage, hash: Data) {}
    public func peer(_ peer: Peer, didReceiveTransaction transaction: Transaction, hash: Data) {}
    public func peer(_ peer: Peer, didReceiveRejectMessage message: RejectMessage) {}
}
