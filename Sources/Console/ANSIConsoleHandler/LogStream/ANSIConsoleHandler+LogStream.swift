import Logging

extension ANSIConsoleHandler {
    public func logStream(
        level: Logger.Level,
        name: String,
        file: StaticString,
        line: UInt
    ) async throws -> LogSink {
        guard level >= self.logLevel else {
            return NoOpLogSink()
        }

        let component = LogStreamComponent(state: .init(name: name, level: level))
        let sink = ComponentLogSink(component: component)

        guard let activeContainer = ConsoleContext.current.activeContainer else {
            throw ConsoleHandlerError.noActiveTrace
        }

        await activeContainer.add(child: component)

        return sink
    }
}
