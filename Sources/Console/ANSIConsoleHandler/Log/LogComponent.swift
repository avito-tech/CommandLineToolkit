import Logging

struct LogComponent: ConsoleComponent {
    let state: LogComponentState
    var result: Result<Void, Error>? { .success(()) }

    var canBeCollapsed: Bool {
        return state.level < .notice
    }

    func handle(event: ConsoleControlEvent) {
    }

    func renderer() -> some Renderer<Void> {
        LogComponentRenderer()
            .withCache()
            .withState(state: state)
    }
}
