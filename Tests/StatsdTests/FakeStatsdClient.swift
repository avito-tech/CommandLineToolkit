import Foundation
import Statsd

final class FakeStatsdClient: StatsdClient {
    var state: StatsdClientState
    
    var sentData: [Data] = []
    var stateUpdateHandler: ((StatsdClientState) -> ())?
    
    var onSend: (Data, @escaping (Error?) -> ()) -> () = { $1(nil) }
    
    init(initialState: StatsdClientState) {
        state = initialState
    }
    
    func cancel() {
        update(state: .notReady)
    }
    
    func start(queue: DispatchQueue) {}
    
    func send(content: Data, completion: @escaping (Error?) -> ()) {
        sentData.append(content)
        onSend(content, completion)
    }
    
    func update(state: StatsdClientState) {
        self.state = state
        self.stateUpdateHandler?(state)
    }
}
