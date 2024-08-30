import Logging

extension ANSIConsoleHandler {
    public func logStream(
        level: Logger.Level,
        name: String,
        renderTail: Int,
        file: StaticString,
        line: UInt
    ) -> LogSink {
        let component = LogStreamComponent(state: .init(name: name, level: level, renderTail: renderTail))
        let sink = ComponentLogSink(component: component)

        guard let activeContainer = ConsoleContext.current.activeContainer else {
            preconditionFailure("No active trace for log stream", file: file, line: line)
        }

        activeContainer.add(child: component)

        return sink
    }
}
