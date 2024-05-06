import Foundation
import Logging

public enum Progress: Sendable {
    case fraction(Double)
    case discrete(current: Int, total: Int)
}

public enum TraceOperationState<Value: Sendable>: Sendable {
    case started
    case progress(Progress)
    case finished(Result<Value, Error>)

    var finished: Result<Value, Error>? {
        if case let .finished(value) = self { return value } else { return nil }
    }
}

public enum TraceMode: Sendable {
    case verbose
    case collapseFinished
    case countSubtraces
}

struct TraceComponentState<Value> {
    var children: [any ConsoleComponent] = []

    var level: Logger.Level
    var name: String
    var mode: TraceMode
    var verbose: Bool
    var operationState: TraceOperationState<Value>?
    var startTime: CFAbsoluteTime?
    var endTime: CFAbsoluteTime?
    var frame: Int = 0
    var frames: [String] = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
}
