import Foundation
import Socket
import SocketModels
import Statsd
import TestHelpers
import XCTest

final class StatsdClientTests: XCTestCase {
    private let socket = assertDoesNotThrow {
        try Socket.create(type: .datagram, proto: .udp)
    }
    private let port = ValueOf<SocketModels.Port>()
    private let queue = OperationQueue()
    
    private lazy var client = assertDoesNotThrow {
        try StatsdClientImpl(
            statsdSocketAddress: SocketAddress(
                host: "127.0.0.1",
                port: assertDoesNotThrow {
                    try resolvePort(
                        queue: queue,
                        timeout: 10
                    )
                }
            )
        )
    }
    
    func test___writing_data_to_socket() throws {
        var dataStream = Data()
        let dataDelivered = XCTestExpectation()
        
        readDatagrams(
            queue: queue,
            onData: {
                dataStream.append(contentsOf: $0)
                dataDelivered.fulfill()
            }
        )
        
        client.send(content: Data([1, 2, 3]), queue: .global()) { error in
            assertNil { error }
        }
        
        wait(for: dataDelivered, timeout: 10)
        
        assert {
            dataStream
        } equals: {
            Data([1, 2, 3])
        }
    }
    
    func test___callback_with_error() throws {
        let sendCompleteExpectation = XCTestExpectation()
        client.send(content: Data([1, 2, 3]), queue: .global()) { error in
            assertNotNil { error }
            sendCompleteExpectation.fulfill()
        }
        wait(for: sendCompleteExpectation, timeout: 60)
    }
    
    private func readDatagrams(
        queue: OperationQueue,
        onData: @escaping (Data) -> (),
        shouldKeepReading: @escaping () -> Bool = { true }
    ) {
        queue.addOperation { [socket] in
            do {
                while true {
                    var data = Data()
                    _ = try socket.listen(forMessage: &data, on: 0)
                    
                    onData(data)
                    if !shouldKeepReading() {
                        break
                    }
                }
            } catch {}
        }
    }
    
    private func resolvePort(
        queue: OperationQueue,
        timeout: TimeInterval
    ) throws -> SocketModels.Port {
        let startDate = Date()
        
        queue.addOperation { [port, socket] in
            while socket.signature?.port ?? 0 <= 0 {
                if Date().timeIntervalSince(startDate) > timeout {
                    break
                }
            }
            port.set(SocketModels.Port(value: Int(assertNotNil { socket.signature?.port })))
        }
        return try port.getWhenAvailable(testCase: self, timeout: timeout)
    }
}
