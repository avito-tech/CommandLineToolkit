import Foundation
import Statsd

final class FakeStatsdClient: StatsdClient {
    var sentData: [Data] = []
    
    init() {
        
    }

    var onTearDown: (DispatchQueue, TimeInterval, @escaping () -> ()) -> () = { queue, _, callback in
        queue.async {
            callback()
        }
    }
    
    func tearDown(queue: DispatchQueue, timeout: TimeInterval, completion: @escaping () -> ()) {
        onTearDown(queue, timeout, completion)
    }
    
    var onSend: (Data, @escaping (Error?) -> ()) -> () = { $1(nil) }

    func send(content: Data, queue: DispatchQueue, completion: @escaping (Error?) -> ()) {
        sentData.append(content)
        onSend(content, completion)
    }
}
