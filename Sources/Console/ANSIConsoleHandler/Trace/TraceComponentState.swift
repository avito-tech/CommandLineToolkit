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

public struct TraceOptions: RawRepresentable, OptionSet, Hashable {
    public var rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let collapseFinished: Self = .init(rawValue: 1 << 0)
    public static let countSubtraces: Self = .init(rawValue: 1 << 1)
}

extension TraceOptions: CustomStringConvertible {
    public var description: String {
        let optionNames = [
            (TraceOptions.collapseFinished, "collapseFinished"),
            (TraceOptions.countSubtraces, "countSubtraces"),
        ]
        
        let optionsString = optionNames
            .compactMap { option, name in
                if self.contains(option) {
                    return name
                } else {
                    return nil
                }
            }
            .joined(separator: ", ")
        
        return "[\(optionsString)]"
    }
}

struct TraceComponentState<Value> {
    var level: Logger.Level
    var name: String
    var options: TraceOptions
    var operationState: TraceOperationState<Value>?
    var startTime: TraceClock.Instant?
    var endTime: TraceClock.Instant?
    var frame: Int = 0
    var frames: [String] = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
}
