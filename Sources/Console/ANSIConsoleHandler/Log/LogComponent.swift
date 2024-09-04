import Logging

struct LogComponent: ConsoleComponent {
    let state: LogComponentState
    var result: Result<Void, Error>? { .success(()) }

    var isVisible: Bool {
        let verbositySettings = ConsoleContext.current.verbositySettings
        return verbositySettings.verbose || state.level >= verbositySettings.logLevel
    }
    
    func canBeCollapsed(at level: Logger.Level) -> Bool {
        let verbositySettings = ConsoleContext.current.verbositySettings
        return !verbositySettings.verbose && state.level <= level
    }

    func handle(event: ConsoleControlEvent) {
    }

    func renderer() -> some Renderer<Void> {
        LogComponentRenderer()
            .withCache()
            .withState(state: state)
    }
}
