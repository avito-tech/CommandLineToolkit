struct InputComponentRenderer: Renderer {
    func render(state: InputComponentState, preferredSize: Size?) -> ConsoleRender {
        switch state.result {
        case nil:
            return renderInProgress(state: state, preferredSize: preferredSize)
        case .cancelled:
            return renderCancelled(state: state, preferredSize: preferredSize)
        case let .success(input):
            return renderFinished(state: state, input: input, preferredSize: preferredSize)
        }
    }

    private func renderInProgress(state: InputComponentState, preferredSize: Size?) -> ConsoleRender {
        let text: ConsoleText = state.input.isEmpty
            ? "\(state.defaultValue ?? state.input, style: .help)"
            : "\(state.input)"

        let prompt: ConsoleText = "\(.blockBorderSymbol) \(.inputSymbol) "
        let title = titleLines(state.title, preferredSize: preferredSize, style: .headerTitle)
        let width = preferredSize.map { max(1, $0.cols - 2) } ?? .max
        let help = state.help?
            .wrapped(to: width)
            .map { "\(.blockBorderSymbol) \($0, style: .help)" as ConsoleText } ?? []

        return .init(
            lines: title + help + [
                "\(prompt)\(text)",
                "\(.blockEndSymbol)"
            ],
            cursorPosition: .init(row: title.count + help.count, col: 1 + prompt.description.count + state.cursorIndex)
        )
    }

    private func renderCancelled(state: InputComponentState, preferredSize: Size?) -> ConsoleRender {
        return .init(
            lines: titleLines(state.title, preferredSize: preferredSize, style: .error) + [
                "\(.blockEndSymbol, style: .error) \(.cancelSymbol, style: .error)"
            ]
        )
    }

    private func renderFinished(state: InputComponentState, input: String, preferredSize: Size?) -> ConsoleRender {
        return .init(
            lines: titleLines(state.title, preferredSize: preferredSize, style: .success) + [
                "\(.blockBorderSymbol, style: .success) \(input)",
                "\(.blockEndSymbol, style: .success)"
            ]
        )
    }

    private func titleLines(
        _ title: String,
        preferredSize: Size?,
        style: ConsoleStyle
    ) -> [ConsoleText] {
        let width = preferredSize.map { max(1, $0.cols - 2) } ?? .max
        return title.wrapped(to: width).enumerated().map { offset, line in
            "\(offset == 0 ? .blockStartSymbol : .blockBorderSymbol, style: style) \(line, style: style)"
        }
    }
}
