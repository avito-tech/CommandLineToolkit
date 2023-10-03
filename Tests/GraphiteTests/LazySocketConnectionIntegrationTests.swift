@testable import Graphite
import AtomicModels
import Foundation
import Socket
import SocketModels
import TestHelpers
import XCTest

final class LazySocketConnectionTests: XCTestCase {
    private let host = "127.0.0.1"
    private let port = 42100
    private let serverSocket = assertDoesNotThrow {
        try Socket.create(family: .inet, type: .stream, proto: .tcp)
    }

    private lazy var socketConnection = LazySocketConnection(
        socketAddress: SocketAddress(
            host: host,
            port: Port(value: port)
        ),
        socketFactory: { try Socket.create(family: .inet, type: .stream, proto: .tcp) }
    )

    private let queue = OperationQueue()

    func test___retries() throws {
        try serverSocket.listen(on: port, node: host)

        let testData = ["1", "2", "3"]
        testData.forEach { input in
            assertDoesNotThrow { try socketConnection.send(data: assertNotNil { input.data(using: .utf8) }) }
            let result = readServerSocketAndCloseClient()

            assert { result } equals: { input }

            waitForClientSocketDisconnected()
        }
    }

    private func readServerSocketAndCloseClient() -> String {
        var result: String?
        let doneExpectation = XCTestExpectation(description: "Read done")
        queue.addOperation { [serverSocket] in
            do {
                let client = try serverSocket.acceptClientConnection()
                defer { client.close() }

                result = try client.readString()
            } catch {}

            doneExpectation.fulfill()
        }

        wait(for: [doneExpectation], timeout: 5)

        return assertNotNil { result }
    }

    private func waitForClientSocketDisconnected() {
        let shouldPoll = AtomicValue<Bool>(true)
        let disconnectExpectation = XCTestExpectation(description: "Socket disconnected")
        queue.addOperation { [socketConnection] in
            let pollInterval = 0.1
            let testData = Data(repeating: 0, count: 1)
            while shouldPoll.currentValue() {
                do {
                    try socketConnection.send(data: testData, retriesLimit: 0)
                } catch {
                    break
                }
                usleep(useconds_t(pollInterval * 1e6))
            }

            disconnectExpectation.fulfill()
        }

        wait(for: [disconnectExpectation], timeout: 3)

        shouldPoll.set(false)
    }
}
