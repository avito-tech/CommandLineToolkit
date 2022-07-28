import Dispatch
import Foundation

public protocol StatsdClient: AnyObject {
    func send(
        content: Data,
        queue: DispatchQueue,
        completion: @escaping (Error?) -> ()
    )
    
    func tearDown(
        queue: DispatchQueue,
        timeout: TimeInterval,
        completion: @escaping () -> ()
    )
}
