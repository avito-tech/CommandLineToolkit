#if os(macOS)
import Foundation
import Network
import SocketModels
import Waitable

// swiftlint:disable async
public final class AppleStatsdClient: StatsdClient {
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
    
    private func handleConnectionStateUpdate(_ updatedState: NWConnection.State) {
        self.stateUpdateHandler?(updatedState.statsdState)
    }
    
    public var stateUpdateHandler: ((StatsdClientState) -> ())?
    
    public var state: StatsdClientState {
        return connection.state.statsdState
    }
    
    public func start(queue: DispatchQueue) {
        connection.stateUpdateHandler = { [weak self] newState in
            self?.handleConnectionStateUpdate(newState)
        }
        
        connection.start(queue: queue)
    }
    
    public func cancel() {
        connection.cancel()
    }
    
    public func send(content: Data, completion: @escaping (Error?) -> ()) {
        connection.send(
            content: content,
            completion: NWConnection.SendCompletion.contentProcessed { error in
                completion(error)
            }
        )
    }
}

extension NWConnection.State {
    var statsdState: StatsdClientState {
        switch self {
        case .setup, .waiting, .preparing, .cancelled:
            return .notReady
        case .ready:
            return .ready
        case .failed:
            return .failed
        @unknown default:
            return .notReady
        }
    }
}
#endif
