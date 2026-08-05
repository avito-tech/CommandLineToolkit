import Foundation

struct QuestionComponentRenderer: Renderer {
    func render(state: QuestionComponentState, preferredSize: Size?) -> ConsoleRender {
        switch state.result {
        case nil:
            return renderInProgress(state: state, preferredSize: preferredSize)
        case .cancelled:
            return renderCancelled(state: state, preferredSize: preferredSize)
        case let .selected(answer):
            return renderFinished(state: state, answer: answer, preferredSize: preferredSize)
        }
    }

    private func renderCancelled(state: QuestionComponentState, preferredSize: Size?) -> ConsoleRender {
        let lines = state.title.wrapped(to: contentWidth(preferredSize)).enumerated().map { offset, line in
            "\(offset == 0 ? .blockStartSymbol : .blockBorderSymbol, style: .error) \(line, style: .error)" as ConsoleText
        }
        return .init(lines: lines + ["\(.blockEndSymbol, style: .error) \(.cancelSymbol, style: .error)"])
    }

    private func renderInProgress(state: QuestionComponentState, preferredSize: Size?) -> ConsoleRender {
        let answerHint = state.defaultAnswer ? "[Y]/n" : "y/[N]"

        let width = contentWidth(preferredSize)
        let titleWidth = max(1, width - answerHint.count - 1)
        let wrappedTitle = state.title.wrapped(to: titleWidth)
        let title = wrappedTitle.enumerated().map { offset, line in
            let prefix: String = offset == 0 ? .blockStartSymbol : .blockBorderSymbol
            if offset == wrappedTitle.indices.last {
                return "\(prefix) \(line, style: .headerTitle) \(answerHint, style: .help)" as ConsoleText
            }
            return "\(prefix) \(line, style: .headerTitle)" as ConsoleText
        }
        let help = state.help?
            .wrapped(to: width)
            .map { "\(.blockBorderSymbol) \($0, style: .help)" as ConsoleText } ?? []
        
        let prompt: ConsoleText = "\(.blockBorderSymbol) \(.inputSymbol) "
        return .init(
            lines: title + help + [
                prompt,
                "\(.blockEndSymbol)"
            ],
            cursorPosition: .init(row: title.count + help.count, col: 1 + prompt.description.count)
        )
    }

    private func renderFinished(state: State, answer: Bool, preferredSize: Size?) -> ConsoleRender {
        let answerContent: ConsoleText = answer
            ? "\(.successSymbol, style: .success)"
            : "\(.failureSymbol, style: .error)"
        let title = state.title.wrapped(to: contentWidth(preferredSize)).enumerated().map { offset, line in
            "\(offset == 0 ? .blockStartSymbol : .blockBorderSymbol, style: .success) \(line, style: .success)" as ConsoleText
        }

        return .init(
            lines: title + [
                "\(.blockBorderSymbol, style: .success) \(answerContent)",
                "\(.blockEndSymbol, style: .success)",
            ]
        )
    }

    private func contentWidth(_ preferredSize: Size?) -> Int {
        preferredSize.map { max(1, $0.cols - 2) } ?? .max
    }
}
