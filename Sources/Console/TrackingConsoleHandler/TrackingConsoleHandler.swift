import Foundation
import Logging

/// Allows to track all interations to be used in analytics
public final class TrackingConsoleHandler: ConsoleHandler {
    private var upstream: ConsoleHandler

    var actionStorage: ConsoleActionStorage

    public init(upstream: ConsoleHandler) {
        self.upstream = upstream
        self.actionStorage = .current
    }

    public var isAtTTY: Bool {
        upstream.isAtTTY
    }

    public var isInteractive: Bool {
        upstream.isInteractive
    }

    public var verbositySettings: ConsoleVerbositySettings {
        upstream.verbositySettings
    }

    public func input(id: String?, title: String, defaultValue: String?, file: StaticString, line: UInt) async throws -> String {
        guard let id else {
            return try await upstream.input(id: id, title: title, defaultValue: defaultValue, file: file, line: line)
        }
        let result = await catching {
            try await upstream.input(id: id, title: title, defaultValue: defaultValue, file: file, line: line)
        }
        await ConsoleActionStorage.current.add(action: .input(id: id, result:  result))
        return try result.get()
    }

    public func question(id: String?, title: String, defaultAnswer: Bool, help: String?, file: StaticString, line: UInt) async throws -> Bool {
        guard let id else {
            return try await upstream.question(id: id, title: title, defaultAnswer: defaultAnswer, help: help, file: file, line: line)
        }
        let result = await catching {
            try await upstream.question(id: id, title: title, defaultAnswer: defaultAnswer, help: help, file: file, line: line)
        }
        await ConsoleActionStorage.current.add(action: .question(id: id, result:  result))
        return try result.get()
    }

    public func select<Value>(id: String?, title: String, values: [Selectable<Value>], mode: SelectionMode, options: SelectionOptions, file: StaticString, line: UInt) async throws -> [Selectable<Value>] {
        guard let id else {
            return try await upstream.select(id: id, title: title, values: values, mode: mode, options: options, file: file, line: line)
        }
        let result = await catching {
            try await upstream.select(id: id, title: title, values: values, mode: mode, options: options, file: file, line: line)
        }
        let trackableResult = result.map { $0.map(\.title) }
        await ConsoleActionStorage.current.add(action: .select(id: id, result: trackableResult))
        return try result.get()
    }

    public func trace<Value>(level: Logging.Logger.Level, id: String?, name: String, options: TraceOptions, file: StaticString, line: UInt, work: (any TraceProgressUpdator) async throws -> Value) async throws -> Value where Value: Sendable {
        guard let id else {
            return try await upstream.trace(level: level, id: id, name: name, options: options, file: file, line: line, work: work)
        }
        let clock = TraceClock()
        let metadata = TraceMetadata()
        let actionStorage = ConsoleActionStorage()
        let start = clock.now

        let result = await catching {
            try await TraceMetadata.$current.withValue(metadata) {
                try await ConsoleActionStorage.$current.withValue(actionStorage) {
                    try await upstream.trace(level: level, id: id, name: name, options: options, file: file, line: line, work: work)
                }
            }
        }

        let trackedActions = await actionStorage.actions

        let end = clock.now

        await ConsoleActionStorage.current.add(action: .trace(
            id: id,
            start: start,
            duration: start.duration(to: end),
            actions: trackedActions,
            metadata: metadata.metadata,
            result: result.map { _ in () }
        ))

        return try result.get()
    }

    public func log(level: Logging.Logger.Level, message: Logging.Logger.Message, metadata: Logging.Logger.Metadata, source: String, file: String, function: String, line: UInt) {
        // skipping logs tracking as of now
        upstream.log(level: level, message: message, metadata: metadata, source: source, file: file, function: function, line: line)
    }

    public func logStream(level: Logging.Logger.Level, name: String, renderTail: Int, file: StaticString, line: UInt) -> any LogSink {
        // skipping logs tracking as of now
        upstream.logStream(level: level, name: name, renderTail: renderTail, file: file, line: line)
    }

    private func catching<Value>(work: () async throws -> Value) async -> Result<Value, Error> {
        do {
            let value = try await work()
            return .success(value)
        } catch {
            return .failure(error)
        }
    }
}
