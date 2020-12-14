import Darwin
import Foundation

public final class SynchronousWaiter: Waiter {
    public init() {}
    
    public func waitWhile(
        pollPeriod: TimeInterval = 0.3,
        timeout: Timeout = .infinity,
        condition: WaitCondition
    ) throws {
        let startTime = Date().timeIntervalSince1970
        
        while try condition() {
            let currentTime = Date().timeIntervalSince1970
            let executionDuration = currentTime - startTime
            if executionDuration > timeout.value {
                throw TimeoutError.waitTimeout(timeout)
            }
            if !RunLoop.current.run(mode: RunLoop.Mode.default, before: Date().addingTimeInterval(pollPeriod)) {
                let passedPollPeriod = Date().timeIntervalSince1970 - currentTime
                if passedPollPeriod < pollPeriod {
                    Thread.sleep(forTimeInterval: pollPeriod - passedPollPeriod)
                }
            }
        }
    }
}
