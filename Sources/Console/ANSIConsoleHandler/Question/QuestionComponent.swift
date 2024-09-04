import Logging
import AtomicModels

final class QuestionComponent: ConsoleComponent {
    @AtomicValue
    var state: QuestionComponentState

    init(state: QuestionComponentState) {
        self.state = state
    }

    var result: Result<Bool, Error>? {
        return state.answer.map(Result.success)
    }

    var isVisible: Bool { true }

    func canBeCollapsed(at level: Logger.Level) -> Bool {
        false
    }

    func handle(event: ConsoleControlEvent) {
        switch event {
        case .inputChar("Y"), .inputChar("y"):
            state.answer = true
        case .inputChar("N"), .inputChar("n"):
            state.answer = false
        case .inputChar("\r"):
            state.answer = state.defaultAnswer
        case let .inputEscapeSequence(code, _):
            if [.up, .down, .left, .right].contains(code) {
                state.defaultAnswer.toggle()
            }
        case .inputChar, .tick:
            break
        }
    }

    func renderer() -> some Renderer<Void> {
        QuestionComponentRenderer()
            .withCache()
            .withState(state: state)
    }
}
