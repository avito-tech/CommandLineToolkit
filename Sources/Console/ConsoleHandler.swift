import Logging

/// Should be used all over the tool to provide consistent CLI experience
public protocol ConsoleHandler {
    var isAtTTY: Bool { get }
    var isInteractive: Bool { get }
    var verbositySettings: ConsoleVerbositySettings { get }

    /// Ask user to input some string
    /// - Parameters:
    ///   - title: question to ask
    ///   - defaultValue: default value, user can hit enter to select it
    /// - Returns: User's input
    func input(
        title: String,
        defaultValue: String?,
        file: StaticString,
        line: UInt
    ) async throws -> String

    /// Ask user a question
    /// - Parameters:
    ///   - title: question to ask
    ///   - defaultAnswer: default answer, yser can just hit enter
    /// - Returns: boolean answer
    func question(
        title: String,
        defaultAnswer: Bool,
        help: String?,
        file: StaticString,
        line: UInt
    ) async throws -> Bool

    /// Select values from a list
    /// - Parameters:
    ///   - title: describes what user selects
    ///   - values: list of possible values
    ///   - options: possible selection options
    /// - Returns: array of selected values
    func select<Value>(
        title: String,
        values: [Selectable<Value>],
        mode: SelectionMode,
        options: SelectionOptions,
        file: StaticString,
        line: UInt
    ) async throws -> [Value]

    /// Runs a chunk of work in a separate Console trace
    ///
    /// This version provides ``TraceProgressUpdator``, so traces operation can report its progress
    ///
    /// - Parameters:
    ///   - level: Trace level, works the same as level in `Logger`
    ///   - name: Name of trace to display
    ///   - mode: Mode in which to run trace, specific modes allow to cleanup nested finished traces
    ///   - work: Work to be performed inside of a trace
    /// - Returns: Value returned form `work` closure
    func trace<Value: Sendable>(
        level: Logger.Level,
        name: String,
        options: TraceOptions,
        file: StaticString,
        line: UInt,
        work: (TraceProgressUpdator) async throws -> Value
    ) async throws -> Value

    /// Renders log, definition the same as in `LogHandler`
    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata,
        source: String,
        file: String,
        function: String,
        line: UInt
    )

    /// Creates a log sink and allows to stream logs from underlying command line instrument
    ///
    /// Should always run in a trace
    ///
    /// - Parameters:
    ///   - level: Log level
    ///   - name: Name of stream
    /// - Returns: ``LogSink`` — an object which receives new log lines and appends those to the stream
    func logStream(
        level: Logger.Level,
        name: String,
        renderTail: Int,
        file: StaticString,
        line: UInt
    ) -> LogSink
}
