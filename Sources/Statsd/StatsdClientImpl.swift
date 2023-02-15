import AtomicModels
import Dispatch
import Foundation
import Socket
import SocketModels

public final class StatsdClientImpl: StatsdClient {
    private let statsdSocketAddress: SocketAddress
    private let group = DispatchGroup()
    private let tornDown = AtomicValue(false)
    
    public struct InvalidSocketAddressError: Error, CustomStringConvertible {
        public let address: SocketAddress
        
        public var description: String {
            "Invalid socket address: \(address)"
        }
    }
    
    public init(
        statsdSocketAddress: SocketAddress
    ) {
        self.statsdSocketAddress = statsdSocketAddress
    }
    
    public func send(
        content: Data,
        queue: DispatchQueue,
        completion: @escaping (Error?) -> ()
    ) {
        guard tornDown.currentValue() == false else {
            return
        }
        
        guard let address = Socket.createAddress(
            for: statsdSocketAddress.host,
            on: Int32(statsdSocketAddress.port.value)
        ) else {
            queue.async { [statsdSocketAddress] in
                completion(InvalidSocketAddressError(address: statsdSocketAddress))
            }
            return
        }
        
        queue.async { [group] in
            group.enter()
            defer {
                group.leave()
            }
            
            do {
                let socket = try Socket.create(
                    type: .datagram,
                    proto: .udp
                )
                defer {
                    socket.close()
                }
                
                try socket.write(
                    from: content,
                    to: address
                )
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func tearDown(
        queue: DispatchQueue,
        timeout: TimeInterval,
        completion: @escaping () -> ()
    ) {
        self.tornDown.set(true)
        
        let tearDownCompleted = AtomicValue(false)
        
        let complete = {
            tearDownCompleted.withExclusiveAccess {
                if $0 == false {
                    $0 = true
                    completion()
                }
            }
        }
        
        group.notify(queue: queue) {
            complete()
        }
        queue.asyncAfter(deadline: .now() + timeout) {
            complete()
        }
    }
}
