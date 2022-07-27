import Foundation

public protocol StatsdClient: AnyObject {
    var stateUpdateHandler: ((StatsdClientState) -> ())? { get set }
    var state: StatsdClientState { get }
    
    func start(queue: DispatchQueue)
    func cancel()
    
    func send(content: Data, completion: @escaping (Error?) -> ())
}
