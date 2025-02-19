import Foundation

struct QuestionComponentRenderer: Renderer {
    func render(state: QuestionComponentState, preferredSize: Size?) -> ConsoleRender {
        switch state.result {
        case nil:
            return renderInProgress(state: state)
        case .cancelled:
            return renderCancelled(state: state)
        case let .selected(answer):
            return renderFinished(state: state, answer: answer)
        }
    }

    private func renderCancelled(state: QuestionComponentState) -> ConsoleRender {
        return .init(lines: ["\(.noBlockSymbol, style: .error) \(state.title, style: .error) \(.cancelSymbol, style: .error)"])
    }

    private func renderInProgress(state: QuestionComponentState) -> ConsoleRender {
        let answerHint = state.defaultAnswer ? "[Y]/n" : "y/[N]"
        
        let help: [ConsoleText]
        if let helpMessage = state.help {
            help = helpMessage.split(separator: "\n").map {
                "\(.blockBorderSymbol) \($0, style: .help)"
            }
        } else {
            help = []
        }
        
        let prompt: ConsoleText = "\(.blockBorderSymbol) \(.inputSymbol) "
        return .init(
            lines: [
                "\(.blockStartSymbol) \(state.title, style: .headerTitle) \(answerHint, style: .help)",
            ] + help + [
                prompt,
                "\(.blockEndSymbol)"
            ],
            cursorPosition: .init(row: 1 + help.count, col: 1 + prompt.description.count)
        )
    }

    private func renderFinished(state: State, answer: Bool) -> ConsoleRender {
        let answerContent: ConsoleText = answer
            ? "\(.successSymbol, style: .success)"
            : "\(.failureSymbol, style: .error)"

        return .init(
            lines: [
                "\(.blockStartSymbol, style: .success) \(state.title, style: .success)",
                "\(.blockBorderSymbol, style: .success) \(answerContent)",
                "\(.blockEndSymbol, style: .success)",
            ]
        )
    }
}
