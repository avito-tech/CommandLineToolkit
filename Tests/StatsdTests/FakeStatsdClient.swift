import Foundation
import Network
import Statsd

final class FakeStatsdClient: StatsdClient {
    var state: NWConnection.State
    
    var sentData: [Data] = []
    var stateUpdateHandler: ((NWConnection.State) -> ())?
    
    var onSend: (Data, @escaping (Error?) -> ()) -> () = { $1(nil) }
    
    init(initialState: NWConnection.State) {
        state = initialState
    }
    
    func cancel() {
        update(state: .cancelled)
    }
    
    func start(queue: DispatchQueue) {}
    
    func send(content: Data, completion: @escaping (Error?) -> ()) {
        sentData.append(content)
        onSend(content, completion)
    }
    
    func update(state: NWConnection.State) {
        self.state = state
        self.stateUpdateHandler?(state)
    }
}
