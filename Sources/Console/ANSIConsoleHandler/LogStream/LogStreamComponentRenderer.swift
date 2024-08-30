import Logging

struct LogStreamComponentRenderer: Renderer {
    func render(state: LogStreamComponentState, preferredSize: Size?) -> ConsoleRender {
        let style: ConsoleStyle = .style(for: state.level)

        let header: ConsoleText = "\(.blockStartSymbol, style: style) \(state.name, style: style)"
        let startLineIndex = state.isFinished ? 0 : max(state.lines.count - state.renderTail, 0)
        let logLines: [ConsoleText] = state.lines[startLineIndex...].map { message in
            "\(.blockBorderSymbol, style: style) \(message, style: style)"
        }
        let footer: ConsoleText = "\(.blockEndSymbol, style: style)"
        return .init(
            lines: [header] + logLines + [footer]
        )
    }
}
