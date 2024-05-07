import Foundation

struct TraceComponentRenderer<Value>: Renderer {
    struct State {
        var childrenRenderers: [AnyRenderer<Void>]
        var progressOverride: Progress?
        var traceState: TraceComponentState<Value>
    }

    func render(state: State, preferredSize: Size?) -> ConsoleRender {
        let borderStyle = ConsoleStyle.from(state: state.traceState.operationState)

        let header = renderHeader(
            state: state.traceState,
            inBlock: !state.childrenRenderers.isEmpty,
            preferredSize: preferredSize,
            progressOverride: state.progressOverride
        )

        if state.childrenRenderers.isEmpty {
            return .init(lines: [header])
        }

        let renders = state.childrenRenderers.map { child in
            child.render(preferredSize: preferredSize.map { .init(rows: $0.rows - 2, cols: $0.cols - 2) })
        }

        let nestedRenders = renders
            .flatMap { child in
                child.lines
            }
            .map { "\(.blockBorderSymbol, style: borderStyle) \($0)" as ConsoleText }

        let cursorProvidingComponentIndex = renders
            .lastIndex { $0.cursorPosition != nil }

        let footer: ConsoleText = "\(.blockEndSymbol, style: borderStyle)"

        guard let cursorProvidingComponentIndex, let requestedPosition = renders[cursorProvidingComponentIndex].cursorPosition else {
            return .init(lines: [header] + nestedRenders + [footer])
        }

        let cursorPosition = renders
            .enumerated()
            .reduce(into: Position(row: 1, col: 2)) { partialResult, component in
                if component.offset < cursorProvidingComponentIndex {
                    partialResult.row += component.element.lines.count
                } else if component.offset == cursorProvidingComponentIndex {
                    partialResult.row += requestedPosition.row
                    partialResult.col += requestedPosition.col
                }
            }

        return .init(
            lines: [header] + nestedRenders + [footer],
            cursorPosition: cursorPosition
        )
    }

    private func executionTime(state: TraceComponentState<Value>, style: ConsoleStyle) -> ConsoleText {
        guard let start = state.startTime else { return "" }
        let end = state.endTime ?? CFAbsoluteTimeGetCurrent()

        let duration = end - start
        let interval = String(format: "%9.5f sec", duration)
        return "\(interval, style: style)"
    }

    private func renderHeader(
        state: TraceComponentState<Value>,
        inBlock: Bool,
        preferredSize: Size?,
        progressOverride: Progress?
    ) -> ConsoleText {
        let operationState: TraceOperationState<Value>?
        if let progressOverride {
            operationState = .progress(progressOverride)
        } else {
            operationState = state.operationState
        }

        let blockStyle: ConsoleStyle = .from(state: state.operationState)
        let titleStyle: ConsoleStyle
        let progress: ConsoleText
        switch operationState {
        case let .progress(.fraction(value)):
            titleStyle = .headerTitle
            progress = String(format: " %.2f%%", value).consoleText(.help)
        case let .progress(.discrete(current, full)):
            titleStyle = .headerTitle
            progress = " [\(current)/\(full)]".consoleText(.help)
        case .finished(.success):
            titleStyle = .success
            progress = " \(.successSymbol, style: .success)"
        case .finished(.failure):
            titleStyle = .error
            progress = " \(.failureSymbol, style: .error)"
        case .started, .none:
            titleStyle = .headerTitle
            let frame = state.frames[Int((Double(state.frame) / Double(ANSIConsoleHandler.targetFps)) * Double(state.frames.count)) % state.frames.count]
            progress = " \(frame, style: .help)"
        }
        let time: ConsoleText = executionTime(state: state, style: titleStyle)

        let lhsPart: ConsoleText = "\(inBlock ? .blockStartSymbol : .noBlockSymbol, style: blockStyle) \(state.name, style: titleStyle)\(progress) "
        let rhsPart: ConsoleText = time

        let expectedWidth = preferredSize?.cols ?? 80
        let spacer = String(repeating: .dashSpacerSymbol, count: expectedWidth - lhsPart.description.count - rhsPart.description.count)

        return "\(lhsPart)\(spacer, style: titleStyle)\(rhsPart)"
    }
}

private extension ConsoleStyle {
    static func from<Value>(state: TraceOperationState<Value>?) -> Self {
        switch state {
        case .finished(.success):
            return .success
        case .finished(.failure):
            return .error
        default:
            return .plain
        }
    }
}
