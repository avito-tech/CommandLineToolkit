/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation
import Socket
import SocketModels

// `LazySocketConnection` will connect socket on demand and reconnect it in case of link failure.
public final class LazySocketConnection {
    public typealias SocketFactory = () throws -> Socket

    private let socketAddress: SocketAddress
    private let socketFactory: SocketFactory

    private var lazySocket: Socket?
    private var socket: Socket {
        get throws {
            if let socket = lazySocket {
                return socket
            }

            let newSocket = try makeConnectedSocket()
            lazySocket = newSocket
            return newSocket
        }
    }

    public init(
        socketAddress: SocketAddress,
        socketFactory: @escaping SocketFactory
    ) {
        self.socketAddress = socketAddress
        self.socketFactory = socketFactory
    }

    public func send(data: Data, retriesLimit: Int = 1) throws {
        try send(data: data, tryNumber: 0, retriesLimit: retriesLimit)
    }

    public func close() {
        lazySocket?.close()
        lazySocket = nil
    }

    private func send(data: Data, tryNumber: Int, retriesLimit: Int) throws {
        do {
            try socket.write(from: data)
        } catch {
            lazySocket?.close()
            lazySocket = nil

            if tryNumber < retriesLimit {
                try send(data: data, tryNumber: tryNumber + 1, retriesLimit: retriesLimit)
            } else {
                throw error
            }
        }
    }

    private func makeConnectedSocket() throws -> Socket {
        let socket = try socketFactory()
        try socket.connect(
            to: socketAddress.host,
            port: Int32(socketAddress.port.value)
        )
        return socket
    }
}
