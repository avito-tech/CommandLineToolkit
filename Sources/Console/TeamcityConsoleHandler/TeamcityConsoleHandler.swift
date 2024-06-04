import Foundation
import Logging
import TeamcityMessaging

public final class TeamcityConsoleHandler: ConsoleHandler {
    struct ConsoleError: Error {
        enum Reason {
            case unsupportedOperation
        }

        var reason: Reason
        var file: StaticString
        var line: UInt
    }

    let terminal: ANSITerminal

    public var isAtTTY: Bool {
        return isatty(STDOUT_FILENO) > 0
    }

    public var isInteractive: Bool {
        #if Xcode
        return false
        #else
        return isAtTTY
        #endif
    }

    public var logLevel: Logger.Level
    public var verbose: Bool

    private let messageGenerator: TeamcityMessageGenerator
    private let messageRenderer: TeamcityMessageRenderer

    public init(
        terminal: ANSITerminal = .shared,
        logLevel: Logger.Level = .info,
        verbose: Bool = false,
        messageGenerator: TeamcityMessageGenerator,
        messageRenderer: TeamcityMessageRenderer
    ) {
        self.terminal = terminal
        self.logLevel = logLevel
        self.verbose = verbose
        self.messageGenerator = messageGenerator
        self.messageRenderer = messageRenderer
    }

    public func input(
        title: String,
        defaultValue: String?,
        file: StaticString,
        line: UInt
    ) async throws -> String {
        throw ConsoleError(reason: .unsupportedOperation, file: file, line: line)
    }
    
    public func question(
        title: String,
        defaultAnswer: Bool,
        file: StaticString,
        line: UInt
    ) async throws -> Bool {
        throw ConsoleError(reason: .unsupportedOperation, file: file, line: line)
    }
    
    public func select<Value>(
        title: String,
        values: [Selectable<Value>],
        mode: SelectionMode,
        options: SelectionOptions,
        file: StaticString,
        line: UInt
    ) async throws -> [Value] {
        throw ConsoleError(reason: .unsupportedOperation, file: file, line: line)
    }
    
    public func trace<Value: Sendable>(
        level: Logging.Logger.Level,
        name: String,
        mode: TraceMode,
        file: StaticString,
        line: UInt,
        work: (any TraceProgressUpdator) async throws -> Value
    ) async throws -> Value {
        let flowId = UUID()

        log(controlMessage: messageGenerator.flowStarted(
            name: name,
            timestamp: Date(),
            flowId: flowId.uuidString,
            parentFlowId: ConsoleContext.current.activeFlow?.uuidString
        ))

        defer {
            log(controlMessage: messageGenerator.flowFinished(timestamp: Date(), flowId: flowId.uuidString))
        }

        log(controlMessage: messageGenerator.blockOpenend(
            name: name,
            timestamp: Date(),
            flowId: flowId.uuidString
        ))

        defer {
            log(controlMessage: messageGenerator.blockClosed(
                name: name,
                timestamp: Date(),
                flowId: flowId.uuidString
            ))
        }

        return try await ConsoleContext.$current.withValue(ConsoleContext.current(with: \.activeFlow, value: flowId)) {
            return try await work(NoOpTraceProgressUpdator())
        }
    }

    public func log(
        level: Logging.Logger.Level,
        message: Logging.Logger.Message,
        metadata: Logging.Logger.Metadata,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        guard level >= self.logLevel else { return }
        log(controlMessage: messageGenerator.message(
            text: "\(level.teamcityLevelPrefix): \(message.description)" + (prettify(metadata).map { "\n\($0)" } ?? ""),
            status: MessageStatus(level: level),
            timestamp: Date(),
            flowId: ConsoleContext.current.activeFlow?.uuidString
        ))
    }

    private func prettify(_ metadata: Logger.Metadata) -> String? {
        return !metadata.isEmpty
            ? metadata.lazy.sorted(by: { $0.key < $1.key }).map { "\($0)=\($1)" }.joined(separator: " ")
            : nil
    }

    public func logStream(
        level: Logging.Logger.Level,
        name: String,
        file: StaticString,
        line: UInt
    ) -> any LogSink {
        let flowId = UUID()

        log(controlMessage: messageGenerator.flowStarted(
            name: name,
            timestamp: Date(),
            flowId: flowId.uuidString,
            parentFlowId: ConsoleContext.current.activeFlow?.uuidString
        ))

        log(controlMessage: messageGenerator.blockOpenend(
            name: name,
            timestamp: Date(),
            flowId: flowId.uuidString
        ))

        return TeamcityLogSink(flowId: flowId) { message in
            self.log(controlMessage: self.messageGenerator.message(
                text: message,
                status: MessageStatus(level: level),
                timestamp: Date(),
                flowId: flowId.uuidString
            ))
        } end: {
            self.log(controlMessage: self.messageGenerator.blockClosed(
                name: name,
                timestamp: Date(),
                flowId: flowId.uuidString
            ))
            self.log(controlMessage: self.messageGenerator.flowFinished(timestamp: Date(), flowId: flowId.uuidString))
        }
    }

    private func log(controlMessage: ControlMessage) {
        guard let message = try? messageRenderer.renderControlMessage(controlMessage: controlMessage) else {
            return
        }
        terminal.writeln(message)
    }
}

extension ConsoleContext {
    private enum ActiveFlow: ConsoleContextKey {
        static let defaultValue: UUID? = nil
    }

    var activeFlow: UUID? {
        get { self[ActiveFlow.self] }
        set { self[ActiveFlow.self] = newValue }
    }
}

private struct TeamcityLogSink: LogSink {
    let flowId: UUID

    let log: (String) -> ()
    let end: () -> ()

    func append(line: String) {
        log(line)
    }

    func append(lines: [String]) {
        for line in lines {
            log(line)
        }
    }

    func finish() {
        end()
    }
}

private extension Logger.Level {
    var teamcityLevelPrefix: String {
        switch self {
        case .trace:
            "TRACE"
        case .debug:
            "DEBUG"
        case .info:
            "INFO"
        case .notice:
            "NOTICE"
        case .warning:
            "WARNING"
        case .error:
            "ERROR"
        case .critical:
            "CRITICAL"
        }
    }
}

private extension MessageStatus {
    init(level: Logging.Logger.Level) {
        switch level {
        case .trace, .debug, .info:
            self = .normal
        case .notice, .warning:
            self = .warning
        case .error, .critical:
            self = .failure
        }
    }
}
