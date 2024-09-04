import Logging

struct LogStreamComponentRenderer: Renderer {
    func render(state: LogStreamComponentState, preferredSize: Size?) -> ConsoleRender {
        let style: ConsoleStyle = .style(for: state.isFailure ? .error : state.level)

        let status: ConsoleText
        switch state.result {
        case nil:
            let frame = state.frames[Int((Double(state.frame) / Double(ANSIConsoleHandler.targetFps)) * Double(state.frames.count)) % state.frames.count]
            status = "\(frame, style: .help)"
        case .success:
            status = "\(.successSymbol, style: .success)"
        case .failure where state.isCancelled:
            status = "\(.cancelSymbol, style: .error)"
        case .failure:
            status = "\(.failureSymbol, style: .error)"
        }
        
        let header: ConsoleText = "\(.blockStartSymbol, style: style) \(state.name, style: style) \(status)"
        
        let logLines: [ConsoleText]
        
        if state.isCancelled {
            logLines = [
                "\(.blockBorderSymbol, style: style) \("Task cancelled", style: style)"
            ]
        } else {
            let startLineIndex = state.isFinished ? 0 : max(state.lines.count - state.renderTail, 0)
            logLines = state.lines[startLineIndex...].map { message in
                "\(.blockBorderSymbol, style: style) \(message, style: style)"
            }
        }
        let footer: ConsoleText = "\(.blockEndSymbol, style: style)"
        
        return .init(
            lines: [header] + logLines + [footer]
        )
    }
}
