struct InputComponentRenderer: Renderer {
    func render(state: InputComponentState, preferredSize: Size?) -> ConsoleRender {
        switch state.result {
        case nil:
            return renderInProgress(state: state)
        case .cancelled:
            return renderCancelled(state: state)
        case let .success(input):
            return renderFinished(state: state, input: input)
        }
    }

    private func renderInProgress(state: InputComponentState) -> ConsoleRender {
        let text: ConsoleText = state.input.isEmpty
            ? "\(state.defaultValue ?? state.input, style: .help)"
            : "\(state.input)"

        let prompt: ConsoleText = "\(.blockBorderSymbol) \(.inputSymbol) "

        return .init(
            lines: [
                "\(.blockStartSymbol) \(state.title, style: .headerTitle)",
                "\(prompt)\(text)",
                "\(.blockEndSymbol)"
            ],
            cursorPosition: .init(row: 1, col: 1 + prompt.description.count + state.cursorIndex)
        )
    }

    private func renderCancelled(state: InputComponentState) -> ConsoleRender {
        return .init(
            lines: ["\(.noBlockSymbol, style: .error) \(state.title, style: .error) \(.cancelSymbol, style: .error)"]
        )
    }

    private func renderFinished(state: InputComponentState, input: String) -> ConsoleRender {
        return .init(
            lines: [
                "\(.blockStartSymbol, style: .success) \(state.title, style: .success)",
                "\(.blockBorderSymbol, style: .success) \(input)",
                "\(.blockEndSymbol, style: .success)"
            ]
        )
    }
}
