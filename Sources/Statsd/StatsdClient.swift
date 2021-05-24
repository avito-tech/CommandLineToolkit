import Foundation
import Network

public protocol StatsdClient: AnyObject {
    var stateUpdateHandler: ((NWConnection.State) -> ())? { get set }
    var state: NWConnection.State { get }
    
    func start(queue: DispatchQueue)
    func cancel()
    
    func send(content: Data, completion: @escaping (Error?) -> ())
}
