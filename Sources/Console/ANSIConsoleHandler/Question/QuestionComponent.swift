import Logging
import AtomicModels

final class QuestionComponent: ConsoleComponent {
    @AtomicValue
    var state: QuestionComponentState

    init(state: QuestionComponentState) {
        self.state = state
    }

    var result: Result<Bool, Error>? {
        switch state.result {
        case nil:
            return nil
        case .cancelled:
            return .failure(CancellationError())
        case let .selected(answer):
            return .success(answer)
        }
    }

    var isVisible: Bool { true }

    func canBeCollapsed(at level: Logger.Level) -> Bool {
        false
    }

    func handle(event: ConsoleControlEvent) {
        switch event {
        case .inputChar("Y"), .inputChar("y"):
            state.confirm(answer: true)
        case .inputChar("N"), .inputChar("n"):
            state.confirm(answer: false)
        case .inputChar("\r"):
            state.confirm(answer: state.defaultAnswer)
        case let .inputEscapeSequence(code, _):
            if [.up, .down, .left, .right].contains(code) {
                state.defaultAnswer.toggle()
            }
        case .inputChar, .tick:
            break
        }
        if Task.isCancelled {
            state.cancel()
        }
    }

    func renderer() -> some Renderer<Void> {
        QuestionComponentRenderer()
            .withCache()
            .withState(state: state)
    }
}
