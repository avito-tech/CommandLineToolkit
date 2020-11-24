import Dispatch
import Foundation

public class Waitable {
    private let semaphore = DispatchSemaphore(value: 1)
    
    public init() {}
    
    /// Blocks until signal occurs
    public func wait() {
        semaphore.wait()
        semaphore.wait() // waits here until `signal` is called
        semaphore.signal()
    }
    
    /// Unblocks thread which waits for `wait` call.
    public func signal() {
        semaphore.signal()
    }
}
