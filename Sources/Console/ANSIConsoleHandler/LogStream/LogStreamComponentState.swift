import Logging

public struct LogStreamError: Error {
    public var statusCode: Int32
    
    public init(statusCode: Int32) {
        self.statusCode = statusCode
    }
}

struct LogStreamComponentState {
    var level: Logger.Level
    let name: String
    var renderTail: Int = 1
    var lines: [String] = []
    var result: Result<Void, LogStreamError>?
    var isCancelled: Bool = false
    var frame: Int = 0
    var frames: [String] = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    
    var isFinished: Bool {
        result != nil
    }
    
    var isSuccess: Bool {
        if case .success = result { true } else { false }
    }
    
    var isFailure: Bool {
        if case .failure = result { true } else { false }
    }
}
