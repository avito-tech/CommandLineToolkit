@testable import Console
import Logging

enum MockCLIError: Error {
    case noStubbedInput(title: String)
}

struct MockTraceProgressUpdator: TraceProgressUpdator {
    let handler: MockCLIHandler
    let name: String

    func update(progress: Progress) {
        handler.traceProgressUpdates[name, default: []].append(progress)
    }
}

struct MockLogSink: LogSink {
    func append(line: String) {

    }

    func replace(line: String) {

    }

    func finish(result: Result<Void, LogStreamError>, cancelled: Bool) {
    }
}

public final class MockCLIHandler: ConsoleHandler {
    public var isAtTTY: Bool = false

    public var isInteractive: Bool = false

    public var verbositySettings: ConsoleVerbositySettings = .init(logLevel: .trace, verbose: true)

    public init() {}

    public var traceProgressUpdates: [String: [Progress]] = [:]
    public func trace<Value>(
        level: Logger.Level,
        name: String,
        options: TraceOptions,
        file: StaticString,
        line: UInt,
        work: (TraceProgressUpdator) async throws -> Value
    ) async throws -> Value where Value: Sendable {
        return try await work(MockTraceProgressUpdator(handler: self, name: name))
    }

    public var selectionResults: [String: [Any]] = [:]
    public func select<Value>(
        title: String,
        values: [Selectable<Value>],
        mode: SelectionMode,
        options: SelectionOptions,
        file: StaticString,
        line: UInt
    ) async throws -> [Value] {
        guard let selection = selectionResults[title] as? [Value] else {
            throw MockCLIError.noStubbedInput(title: title)
        }
        return selection
    }

    public var inputs: [String: String] = [:]
    public func input(
        title: String,
        defaultValue: String?,
        file: StaticString,
        line: UInt
    ) async throws -> String {
        guard let input = inputs[title] ?? defaultValue else {
            throw MockCLIError.noStubbedInput(title: title)
        }
        return input
    }

    public var questionAnswers: [String: Bool] = [:]
    public func question(
        title: String,
        defaultAnswer: Bool,
        help: String?,
        file: StaticString,
        line: UInt
    ) async throws -> Bool {
        guard let input = questionAnswers[title] else {
            throw MockCLIError.noStubbedInput(title: title)
        }
        return input
    }

    public var logEntries: [LogComponentState] = []
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        logEntries.append(LogComponentState(
            level: level,
            message: message,
            metadata: metadata,
            source: source,
            file: file,
            function: function,
            line: line
        ))
    }

    public func logStream(
        level: Logger.Level,
        name: String,
        renderTail: Int,
        file: StaticString,
        line: UInt
    ) -> any LogSink {
        MockLogSink()
    }
}
