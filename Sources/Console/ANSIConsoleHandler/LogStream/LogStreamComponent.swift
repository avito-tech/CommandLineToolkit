import Logging
import AtomicModels

final class LogStreamComponent: ConsoleComponent {
    @AtomicValue
    var state: LogStreamComponentState

    init(state: LogStreamComponentState) {
        self.state = state
    }

    var result: Result<Void, Error>? {
        state.result?.mapError { $0 }
    }

    var isVisible: Bool {
        let verbositySettings = ConsoleContext.current.verbositySettings
        return verbositySettings.verbose || state.level >= verbositySettings.logLevel || state.isFailure
    }
    
    func canBeCollapsed(at level: Logger.Level) -> Bool {
        let verbositySettings = ConsoleContext.current.verbositySettings
        return !verbositySettings.verbose && state.level <= level && state.isSuccess
    }

    func handle(event: ConsoleControlEvent) {
        switch event {
        case .tick:
            state.frame = (state.frame + 1) % 60
        default:
            break
        }
    }

    func renderer() -> some Renderer<Void> {
        LogStreamComponentRenderer()
            .withState(state: state)
    }

    func append(line: String) {
        state.lines.append(line)
    }

    func replace(line: String) {
        state.lines.removeLast()
        state.lines.append(line)
    }

    func finish(result: Result<Void, LogStreamError>, cancelled: Bool) {
        state.result = result
        state.isCancelled = cancelled
    }
}

public protocol LogSink {
    func append(line: String)
    func replace(line: String)
    func finish(result: Result<Void, LogStreamError>, cancelled: Bool)
}

final class ComponentLogSink: LogSink {
    let component: LogStreamComponent

    init(component: LogStreamComponent) {
        self.component = component
    }
    
    deinit {
        if component.isUnfinished {
            component.finish(result: .success(()), cancelled: Task.isCancelled)
        }
    }

    func append(line: String) {
        component.append(line: line)
    }

    func replace(line: String) {
        component.replace(line: line)
    }

    func finish(result: Result<Void, LogStreamError>, cancelled: Bool) {
        component.finish(result: result, cancelled: cancelled)
    }
}

struct NoOpLogSink: LogSink {
    func append(line: String) {
    }

    func replace(line: String) {
    }

    func finish(result: Result<Void, LogStreamError>, cancelled: Bool) {
    }
}

struct LogHandlerSink: LogSink {
    var level: Logger.Level = .debug
    var logHandler: LogHandler
    
    func append(line: String) {
        logHandler.log(
            level: level,
            message: "\(line)",
            metadata: nil,
            source: "ANSIConsoleHandler",
            file: #fileID,
            function: #function,
            line: #line
        )
    }
    
    func replace(line: String) {
        append(line: line)
    }
    
    func finish(result: Result<Void, LogStreamError>, cancelled: Bool) {
    }
}
