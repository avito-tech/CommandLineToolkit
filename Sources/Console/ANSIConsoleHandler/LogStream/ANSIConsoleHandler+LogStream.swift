import Logging

extension ANSIConsoleHandler {
    public func logStream(
        level: Logger.Level,
        name: String,
        renderTail: Int,
        file: StaticString,
        line: UInt
    ) -> LogSink {
        guard let activeContainer = ConsoleContext.current.activeContainer else {
            return LogHandlerSink(level: level, logHandler: ConsoleLogHandler(handler: self, label: name))
        }

        let component = LogStreamComponent(state: .init(level: level, name: name, renderTail: renderTail))

        let sink = ComponentLogSink(component: component)

        activeContainer.add(child: component)

        return sink
    }
}
