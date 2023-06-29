/// Entrypoint for setting default ``ConsoleHandler``
public enum ConsoleSystem {
    fileprivate static let lock = ReadWriteLock()
    fileprivate static var factory: () -> ConsoleHandler = { ANSIConsoleHandler(terminal: .shared) }
    fileprivate static var initialized = false

    /// `bootstrap` is a one-time configuration function which globally selects the desired console backend
    /// implementation. `bootstrap` can be called at maximum once in any given program, calling it more than once will
    /// lead to undefined behavior, most likely a crash.
    ///
    /// - parameters:
    ///     - factory: A closure that given a `Logger` identifier, produces an instance of the `LogHandler`.
    public static func bootstrap(_ factory: @escaping () -> ConsoleHandler) {
        self.lock.withWriterLock {
            precondition(!self.initialized, "console system can only be initialized once per process.")
            self.factory = factory
            self.initialized = true
        }
    }

    // for our testing we want to allow multiple bootstraping
    static func bootstrapInternal(_ factory: @escaping () -> ConsoleHandler) {
        self.lock.withWriterLock {
            self.factory = factory
        }
    }
}

extension Console {
    /// Initialize with preconfigured ``ConsoleHandler`` from factory supplied to ``ConsoleSystem``
    public init() {
        self.init(handler: ConsoleSystem.lock.withReaderLock { ConsoleSystem.factory() })
    }
}
