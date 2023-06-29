import Foundation

final actor InputComponent: ConsoleComponent {
    var state: InputComponentState

    init(state: InputComponentState) {
        self.state = state
    }

    var result: Result<String, Error>? {
        return state.isFinished ? .success(state.input) : nil
    }

    var canBeCollapsed: Bool { false }

    func handle(event: ConsoleControlEvent) {
        let index = state.input.index(state.input.startIndex, offsetBy: state.cursorIndex)

        switch event {
        case .inputChar(.enter):
            if state.input.isEmpty, let value = state.defaultValue {
                state.input = value
                state.cursorIndex = state.input.count
            }
            state.isFinished = true
        case .inputChar(.del):
            guard !state.input.isEmpty, index > state.input.startIndex else {
                break
            }
            state.input.remove(at: state.input.index(before: index))
            state.cursorIndex -= 1
        case .inputChar(.tab):
            if state.input.isEmpty, let value = state.defaultValue {
                state.input = value
                state.cursorIndex = state.input.count
            }
        case let .inputChar(char):
            state.input.insert(char, at: index)
            state.cursorIndex += 1
        case .inputEscapeSequence(.left, [.alt]):
            state.cursorIndex = 0
        case .inputEscapeSequence(.left, _) where index > state.input.startIndex:
            state.cursorIndex -= 1
        case .inputEscapeSequence(.right, [.alt]):
            state.cursorIndex = state.input.count
        case .inputEscapeSequence(.right, _) where index < state.input.endIndex:
            state.cursorIndex += 1
        case .inputEscapeSequence, .tick:
            break
        }
    }

    func renderer() -> some Renderer<Void> {
        InputComponentRenderer()
            .withCache()
            .withState(state: state)
    }
}
