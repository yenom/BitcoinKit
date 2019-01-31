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
import Network

private let protocolVersion: Int32 = 70_015
private let minimumProtocolVersion: Int32 = 70_011 // peers earlier than this protocol version does not support bloom filter

class Peer {
    private let identifier: UInt // identifier to distinguish from other peers
    private let connection: NWConnection
    private let concurrentConnectionQueue = DispatchQueue(label: "com.BitcoinKit.connectionQueue", attributes: .concurrent)
    private let network: Network
    private let host: String
    private var address: String?
    let context = Context()
    class Context {
        var sentVerack = false
        var gotVerack = false
        var remoteNodeHeight: Int32 = 0
    }

    init(host: String, network: Network, identifier: UInt) {
        self.host = host
        self.network = network
        self.identifier = identifier
        self.address = nil
        // TODO: init connection with ipv4 or ipv6
//        let uint8: [UInt8] = [122, 135, 173, 247]
//        let ipv4 = IPv4Address("122.135.173.247")
//        connection = NWConnection(host: NWEndpoint.Host.ipv4(ipv4!), port: NWEndpoint.Port(rawValue: UInt16(40263))!, using: .tcp)
        connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(rawValue: UInt16(network.port))!, using: .tcp)
    }

    func connect() {
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                self.log("Connection ready: \(self.connection.endpoint)")
                self.startConnect()
            case .waiting(let error):
                self.log("Connection waiting: \(error)")
            case .failed(let error):
                self.log("Connection failed: \(error)")
            default:
                break
            }
        }
        readHead()
        connection.start(queue: concurrentConnectionQueue)
    }

    private func startConnect() {
        // TODO: check whether handshake is necessary
        sendVersionMessage()
    }

    func disconnect() {
        connection.cancel()
        log("Disconnected")
    }

    private func readHead() {
        connection.receive(minimumIncompleteLength: MessageHeader.length, maximumLength: MessageHeader.length, completion: { [weak self] (data, _, _, error) in
            guard let self = self else {
                print("self is nil")
                return
            }
            if let error = error {
                self.log(error.debugDescription)
                self.disconnect()
                return
            }
            guard let _data = data, let messageHeader = MessageHeader.deserialize(_data) else {
                self.log("failed to deserialize messageHeader: \(String(describing: data?.hex))")
                self.readHead()
                return
            }
            let command: String = messageHeader.command
            let bodyLength = Int(messageHeader.length)
            self.log("Got \(command) message")
            if bodyLength > 0 {
                self.readBody(command: command, bodyLength: bodyLength)
            } else if command == VerackMessage.command {
                self.handleVerackMessage()
            }
            self.readHead()
        })
    }

    private func readBody(command: String, bodyLength: Int) {
        connection.receive(minimumIncompleteLength: bodyLength, maximumLength: bodyLength, completion: { [weak self] (data, _, _, error) in
            guard let self = self else {
                print("self is nil")
                return
            }
            if let error = error {
                self.log(error.debugDescription)
                self.disconnect()
                return
            }
            guard let data = data else {
                self.log("Message (\(command)) has no data")
                return
            }
            do {
                switch command {
                case VersionMessage.command:
                    try self.handleVersionMessage(payload: data)
                case PingMessage.command:
                    self.handlePingMessage(payload: data)
                default:
                    break
                }
            } catch let error {
                print(error)
            }
        })
    }

    // MARK: - Send Message
    private func sendMessage(_ message: Message, completion: (() -> Void)? = nil) {
        let data = message.combineHeader(network.magic)
        connection.send(content: data, completion: .contentProcessed { [weak self] (sendError) in
            guard let strongSelf = self else {
                print("self is nil")
                return
            }
            if let sendError = sendError {
                strongSelf.log("Fail to send \(type(of: message).command): \(sendError.debugDescription)")
            }
            strongSelf.log("Send \(type(of: message).command) message")
            completion?()
        })
    }

    private func sendVersionMessage() {
        let versionMessage = VersionMessage(version: protocolVersion,
                                            services: 0x00,
                                            timestamp: Int64(Date().timeIntervalSince1970),
                                            yourAddress: NetworkAddress(services: 0x00, address: "::ffff:127.0.0.1", port: UInt16(network.port)),
                                            myAddress: NetworkAddress(services: 0x00, address: "::ffff:127.0.0.1", port: UInt16(network.port)),
                                            nonce: 0,
                                            userAgent: "/BitcoinKit:1.0.2/",
                                            startHeight: 0,
                                            relay: false)
        sendMessage(versionMessage)
    }

    private func sendVerackMessage() {
        let verackMessage = VerackMessage()
        sendMessage(verackMessage, completion: { [weak self] in
            guard let self = self else {
                print("self is nil")
                return
            }
            self.context.sentVerack = true
            if self.context.gotVerack {
                self.log("Handshake completed")
            }
        })
    }

    // MARK: - Handle Message
    private func handleVersionMessage(payload: Data) throws {
        let versionMessage = VersionMessage.deserialize(payload)
        guard versionMessage.version >= minimumProtocolVersion else {
            throw PeerError.error("Protocol version \(versionMessage.version) not supported")
        }
        guard versionMessage.services & VersionMessage.nodeBloomService == VersionMessage.nodeBloomService else {
            throw PeerError.error("Node doesn't support SPV mode")
        }
        guard let startHeight = versionMessage.startHeight else {
            throw PeerError.error("Version message doesn't carry startHeight")
        }
        log("Version: \(versionMessage.version) \(versionMessage.userAgent?.value ?? "")")
        self.address = versionMessage.yourAddress.address
        context.remoteNodeHeight = startHeight
        sendVerackMessage()
    }

    private func handleVerackMessage() {
        guard !context.gotVerack else {
            log("Unexpected verack")
            return
        }
        context.gotVerack = true
        if context.sentVerack {
            log("Handshake completed")
        }
    }

    private func handlePingMessage(payload: Data) {
        let ping = PingMessage.deserialize(payload)
        let pong = PongMessage(nonce: ping.nonce)
        sendMessage(pong)
    }

    private func log(_ message: String) {
        print("Peer\(identifier): \(message)")
    }
}

private enum PeerError: Error {
    case error(String)
}
