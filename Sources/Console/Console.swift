import Darwin
import Logging

/// Console entrypoint, should be used in a manner similar to `Logging.Logger`.
///
/// It's just an interface, all hard work is delegated to underlying ``ConsoleHandler``.
public struct Console {
    let handler: ConsoleHandler

    /// Initializes ``Console`` with custom ``ConsoleHandler``
    /// - Parameter handler: Custom console handler to be used with this console
    public init(handler: ConsoleHandler) {
        self.handler = handler
    }
}

// MARK: - Console props

extension Console {
    /// True if application is running at TTY
    public var isAtTTY: Bool {
        handler.isAtTTY
    }

    /// True if application is running in interactive environment
    ///
    /// Xcode's console is not interactive, though it's TTY
    public var isInteractive: Bool {
        handler.isInteractive
    }
}

// MARK: - LogStream extensions

extension Console {
    /// Creates a log sink and allows to stream logs from underlying command line instrument
    ///
    /// Should always run in a trace
    ///
    /// - Parameters:
    ///   - level: Log level
    ///   - name: Name of stream
    /// - Returns: ``LogSink`` — an object which receives new log lines and appends those to the stream
    public func logStream(
        level: Logger.Level = .trace,
        name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> LogSink {
        try runBlocking {
            try await handler.logStream(level: level, name: name, file: file, line: line)
        }
    }

    /// Creates a log sink and allows to stream logs from underlying command line instrument
    ///
    /// Should always run in a trace
    ///
    /// - Parameters:
    ///   - level: Log level
    ///   - name: Name of stream
    /// - Returns: ``LogSink`` — an object which receives new log lines and appends those to the stream
    public func logStream(
        level: Logger.Level = .trace,
        name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> LogSink {
        try await handler.logStream(level: level, name: name, file: file, line: line)
    }
}

// MARK: - Input extensions

extension Console {
    public func input(
        title: String,
        defaultValue: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> String {
        return try await handler.input(
            title: title,
            defaultValue: defaultValue,
            file: file,
            line: line
        )
    }
}

// MARK: - Question extensions

extension Console {
    public func question(
        title: String,
        defaultAnswer: Bool = true,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> Bool {
        return try await handler.question(
            title: title,
            defaultAnswer: defaultAnswer,
            file: file,
            line: line
        )
    }
}

// MARK: - Select extensions

extension Console {
    enum SelectionError: Error {
        case nothingSelected
    }

    /// Select values from a list
    /// - Parameters:
    ///   - title: describes what user selects
    ///   - values: list of possible values
    ///   - options: possible selection options
    /// - Returns: array of selected values
    func select<Value>(
        title: String,
        values: [Selectable<Value>],
        minSelections: Int = 1,
        maxSelections: Int = .max,
        options: SelectionOptions,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [Value] {
        try await handler.select(
            title: title,
            values: values,
            mode: .multiple(min: minSelections, max: maxSelections),
            options: options,
            file: file,
            line: line
        )
    }

    /// Select values from a list
    /// - Parameters:
    ///   - title: describes what user selects
    ///   - values: list of possible values
    ///   - options: possible selection options
    /// - Returns: array of selected values
    public func select<Value: CustomStringConvertible>(
        title: String,
        values: [Value],
        minSelections: Int = 1,
        maxSelections: Int = .max,
        options: SelectionOptions = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> [Value] {
        return try await handler.select(
            title: title,
            values: values.map { .init(title: $0.description, value: $0) },
            mode: .multiple(min: minSelections, max: maxSelections),
            options: options,
            file: file,
            line: line
        )
    }

    /// Select one value from a list
    /// - Parameters:
    ///   - title: describes what user selects
    ///   - values: list of possible values
    /// - Returns: selected value
    public func selectOne<Value>(
        title: String,
        values: [Selectable<Value>],
        options: SelectionOptions = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> Value {
        let selections = try await handler.select(
            title: title,
            values: values,
            mode: .single,
            options: options,
            file: file,
            line: line
        )

        guard let selection = selections.first else {
            throw SelectionError.nothingSelected
        }

        return selection
    }

    /// Select one value from a list
    /// - Parameters:
    ///   - title: describes what user selects
    ///   - values: list of possible values
    /// - Returns: selected value
    public func selectOne<Value: CustomStringConvertible>(
        title: String,
        values: [Value],
        options: SelectionOptions = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> Value {
        return try await selectOne(
            title: title,
            values: values.map { .init(title: $0.description, value: $0) },
            options: options,
            file: file,
            line: line
        )
    }
}

// MARK: - Trace extensions

extension Console {
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
    public func trace<Value: Sendable>(
        level: Logger.Level = .info,
        name: String,
        mode: TraceMode = .verbose,
        file: StaticString = #file,
        line: UInt = #line,
        work: (TraceProgressUpdator) async throws -> Value
    ) async throws -> Value {
        try await handler.trace(
            level: level,
            name: name,
            mode: mode,
            file: file,
            line: line,
            work: work
        )
    }

    /// Runs a chunk of work in a separate Console trace
    ///
    /// - Parameters:
    ///   - level: Trace level, works the same as level in `Logger`
    ///   - name: Name of trace to display
    ///   - mode: Mode in which to run trace, specific modes allow to cleanup nested finished traces
    ///   - work: Work to be performed inside of a trace
    /// - Returns: Value returned form `work` closure
    public func trace<Value: Sendable>(
        level: Logger.Level = .info,
        name: String,
        mode: TraceMode = .verbose,
        file: StaticString = #file,
        line: UInt = #line,
        work: () async throws -> Value
    ) async throws -> Value {
        try await handler.trace(
            level: level,
            name: name,
            mode: mode,
            file: file,
            line: line
        ) { _ in
            try await work()
        }
    }
}

extension Console {
    /// Holds escaped `ConsoleContext` and allows to restore it for specific operation
    public struct ContextContinuation {
        private let context: ConsoleContext

        init(context: ConsoleContext) {
            self.context = context
        }

        /// Restores context and runs operation with this context
        /// - Parameter operation: Operation to run
        /// - Returns: Value returned by operation
        public func yield<Value>(_ operation: () throws -> Value) rethrows -> Value {
            try ConsoleContext.$current.withValue(context, operation: operation)
        }

        /// Restores context and runs operation with this context
        /// - Parameter operation: Operation to run
        /// - Returns: Value returned by operation
        public func yield<Value>(_ operation: () async throws -> Value) async rethrows -> Value {
            try await ConsoleContext.$current.withValue(context, operation: operation)
        }
    }

    /// Intended to bridge structured concurrency world with legacy callback-based world
    ///
    /// Yield continuation as soon as possible in nested callback:
    ///
    /// ```
    /// console.withEscapingContext { continuation in
    ///   legacyClass.runSomething {
    ///     continuation.yield {
    ///       // do all your work here
    ///     }
    ///   }
    /// }
    /// ```
    /// 
    /// - Parameter operation: Operation to be ran with captured `ConsoleContext`
    /// - Returns: Value returned by operation
    public func withEscapingContext<Value>(_ operation: (ContextContinuation) throws -> Value) rethrows -> Value {
        try operation(ContextContinuation(context: .current))
    }

    /// Intended to bridge structured concurrency world with legacy callback-based world
    ///
    /// Yield continuation as soon as possible in nested callback:
    ///
    /// ```
    /// await console.withEscapingContext { continuation in
    ///   legacyClass.runSomething {
    ///     continuation.yield {
    ///       // do all your work here
    ///     }
    ///   }
    /// }
    /// ```
    ///
    /// - Parameter operation: Operation to be ran with captured `ConsoleContext`
    /// - Returns: Value returned by operation
    public func withEscapingContext<Value>(_ operation: (ContextContinuation) async throws -> Value) async rethrows -> Value {
        try await operation(ContextContinuation(context: .current))
    }
}
