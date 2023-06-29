struct InputComponentRenderer: Renderer {
    func render(state: InputComponentState, preferredSize: Size?) -> ConsoleRender {
        if state.isFinished {
            return renderFinished(state: state)
        } else {
            return renderInProgress(state: state)
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

    private func renderFinished(state: InputComponentState) -> ConsoleRender {
        return .init(
            lines: [
                "\(.blockStartSymbol, style: .success) \(state.title, style: .success)",
                "\(.blockBorderSymbol, style: .success) \(state.input)",
                "\(.blockEndSymbol, style: .success)"
            ]
        )
    }
}
