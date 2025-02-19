import Logging

extension ConsoleContext {
    private enum ActiveContainerKey: ConsoleContextKey {
        static let defaultValue: ContainerConsoleComponent? = nil
    }

    var activeContainer: ContainerConsoleComponent? {
        get { self[ActiveContainerKey.self] }
        set { self[ActiveContainerKey.self] = newValue }
    }
}

extension ANSIConsoleHandler {
    /// Run a chunk of work in a scoped CLI environment
    /// - Parameters:
    ///   - title: name of work
    ///   - collapseFinished: collapse finished ``CLICollapsable`` elements
    ///   - work: async work to be performed, should return ``AsyncThrowingStream`` of progress, and always finish in finished progress
    /// - Returns: value from `.finished` progress
    @discardableResult
    public func trace<Value: Sendable>(
        level: Logger.Level,
        name: String,
        options: TraceOptions,
        file: StaticString,
        line: UInt,
        work: (TraceProgressUpdator) async throws -> Value
    ) async throws -> Value {
        try Task.checkCancellation()

        let component = TraceComponent<Value>(
            parent: ConsoleContext.current.activeContainer,
            state: .init(level: level, name: name, options: options)
        )

        guard isInteractive else {
            return try await nonInteractiveTask(name: name, component: component, work: work)
        }

        async let result = run(component, file: file, line: line)

        do {
            try await perform(work: work, in: component)
        } catch {
            // Ignore error as it will be baked into result
        }

        return try await result
    }

    @discardableResult
    private func perform<Value>(
        work: (TraceProgressUpdator) async throws -> Value,
        in component: TraceComponent<Value>
    ) async throws -> Value {
        try await ConsoleContext.$current.withUpdated(key: \.activeContainer, value: component) {
            do {
                component.updateOperationState(state: .started)

                let result = try await work(ComponentTraceProgressUpdator(component: component))

                component.updateOperationState(state: .finished(.success(result)))

                return result
            } catch {
                component.updateOperationState(state: .finished(.failure(error)))
                throw error
            }
        }
    }

    private func nonInteractiveTask<Value: Sendable>(
        name: String,
        component: TraceComponent<Value>,
        work: (TraceProgressUpdator) async throws -> Value
    ) async throws -> Value {
        let indent = indentString()

        renderStatus(name: name, status: .begin, indent: indent)

        do {
            let value = try await perform(work: work, in: component)
            renderStatus(name: name, status: .success, indent: indent)
            return value
        } catch {
            renderStatus(name: name, status: .failure, indent: indent)
            throw error
        }
    }

    private func renderStatus(name: String, status: StatusToRender, indent: String) {
        let statusString: String
        switch status {
        case .begin:
            statusString = "[Begin]"
        case .success:
            statusString = "[Success]"
        case .failure:
            statusString = "[Failure]"
        }
        terminal.writeln("\(indent)\(name) \(statusString)")
    }

    enum StatusToRender {
        case begin
        case success
        case failure
    }
}

public protocol TraceProgressUpdator {
    func update(progress: Progress)
}

public struct ComponentTraceProgressUpdator<Value>: TraceProgressUpdator {
    let component: TraceComponent<Value>

    public func update(progress: Progress) {
        component.updateOperationState(state: .progress(progress))
    }
}

public struct NoOpTraceProgressUpdator: TraceProgressUpdator {
    public func update(progress: Progress) {
    }
}
