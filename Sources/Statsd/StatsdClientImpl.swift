import Foundation
import Network
import SocketModels
import Waitable

// swiftlint:disable async
public final class StatsdClientImpl: StatsdClient {
    struct InvalidPortValue: Error, CustomStringConvertible {
        let value: Int
        var description: String {
            return "Invalid port value \(value)"
        }
    }
    
    private let connection: NWConnection
    
    public init(
        statsdSocketAddress: SocketAddress
    ) throws {
        guard let port = NWEndpoint.Port(rawValue: UInt16(statsdSocketAddress.port.value)) else {
            throw InvalidPortValue(value: statsdSocketAddress.port.value)
        }
        
        self.connection = NWConnection(
            host: .name(statsdSocketAddress.host, nil),
            port: port,
            using: .udp
        )
    }
    
    public var stateUpdateHandler: ((NWConnection.State) -> ())? {
        get { connection.stateUpdateHandler }
        set { connection.stateUpdateHandler = newValue }
    }
    
    public var state: NWConnection.State {
        connection.state
    }
    
    public func start(queue: DispatchQueue) {
        connection.start(queue: queue)
    }
    
    public func cancel() {
        connection.cancel()
    }
    
    public func send(content: Data) {
        let completionQueue = DispatchQueue(label: "statsdClientCompletionQueue")
        
        let waitable = Waitable()
        completionQueue.async { [connection] in
            connection.send(
                content: content,
                completion: NWConnection.SendCompletion.contentProcessed { _ in
                    completionQueue.async {
                        waitable.signal()
                    }
                }
            )
        }
        
        waitable.wait()
    }
}
