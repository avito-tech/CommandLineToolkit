import Foundation
import IO

public class StreamReopener {
    private var lastStreamOpenEventTimestamp: TimeInterval = 0
    private var numberOfAttemptsToReopenStream = 0
    private let maximumAttemptsToReopenStream: Int

    public init(maximumAttemptsToReopenStream: Int) {
        self.maximumAttemptsToReopenStream = maximumAttemptsToReopenStream
    }
    
    private func shouldAttemptToReopenStream() -> Bool {
        let reopenAttemptTimestamp = Date.timeIntervalSinceReferenceDate
        let streamReopenAttemptIsWithinShortTimeRange = (reopenAttemptTimestamp - lastStreamOpenEventTimestamp) < 60
        if streamReopenAttemptIsWithinShortTimeRange {
            numberOfAttemptsToReopenStream += 1
        } else {
            numberOfAttemptsToReopenStream = 0
        }
        return numberOfAttemptsToReopenStream < maximumAttemptsToReopenStream
    }
    
    public func streamHasBeenOpened() {
        lastStreamOpenEventTimestamp = Date.timeIntervalSinceReferenceDate
    }
    
    public func attemptToReopenStream(stream: EasyOutputStream) {
        do {
            if shouldAttemptToReopenStream() {
                stream.close()
                lastStreamOpenEventTimestamp = Date.timeIntervalSinceReferenceDate
                try stream.open()
            } else {
                stream.close()
            }
        } catch {
        }
    }
}
