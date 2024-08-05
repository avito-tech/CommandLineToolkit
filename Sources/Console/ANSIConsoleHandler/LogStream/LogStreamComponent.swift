import Logging

final actor LogStreamComponent: ConsoleComponent {
    var state: LogStreamComponentState

    init(state: LogStreamComponentState) {
        self.state = state
    }

    var result: Result<Void, Error>? {
        if state.isFinished {
            return .success(())
        } else {
            return nil
        }
    }

    var canBeCollapsed: Bool {
        return state.isFinished
    }

    func handle(event: ConsoleControlEvent) {
    }

    func renderer() -> some Renderer<Void> {
        LogStreamComponentRenderer()
            .withCache()
            .withState(state: state)
    }

    func append(lines: [String]) {
        state.lines.append(contentsOf: lines)
    }

    func finish() {
        state.isFinished = true
    }
}

public protocol LogSink {
    func append(line: String) async
    func append(lines: [String]) async
    func finish() async
}

struct ComponentLogSink: LogSink {
    let component: LogStreamComponent

    init(component: LogStreamComponent) {
        self.component = component
    }

    func append(line: String) async {
        await component.append(lines: [line])
    }

    func append(lines: [String]) async {
        await component.append(lines: lines)
    }

    func finish() async {
        await component.finish()
    }
}

struct NoOpLogSink: LogSink {
    func append(line: String) {
    }

    func append(lines: [String]) {
    }

    func finish() {
    }
}

struct LogHandlerSink: LogSink {
    let logHandler: LogHandler
    
    func append(line: String) {
        logHandler.log(
            level: .debug,
            message: "\(line)",
            metadata: nil,
            source: "ANSIConsoleHandler",
            file: #fileID,
            function: #function,
            line: #line
        )
    }
    
    func append(lines: [String]) {
        lines.forEach(self.append(line:))
    }
    
    func finish() {
    }
}
