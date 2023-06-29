struct SelectComponentRenderer<Value>: Renderer {
    func render(state: SelectComponentState<Value>, preferredSize: Size?) -> ConsoleRender {
        if state.isFinished {
            return renderFinished(state: state)
        } else {
            return renderInProgress(state: state, preferredSize: preferredSize)
        }
    }

    private func renderInProgress(state: SelectComponentState<Value>, preferredSize: Size?) -> ConsoleRender {
        let controlsHelp = "([Space] - выбрать, [Enter] - подтвердить, [Shift] - быстро скроллить)"
        let help: String
        switch state.mode {
        case .single:
            help = "выбери один \(controlsHelp)"
        case .multiple(_, .max):
            help = "выбери несколько \(controlsHelp)"
        case let .multiple(_, max):
            help = "выбери несколько [\(state.selectedIds.count)/\(max)] \(controlsHelp)"
        }

        let header: ConsoleText = "\(.blockStartSymbol) \(state.title, style: .headerTitle) \(help, style: .help)"
        let searchPrompt: ConsoleText = "\(.blockBorderSymbol) \(.noBlockSymbol) Найти \(.inputSymbol) "
        let search: ConsoleText = "\(searchPrompt)\(state.search)"
        let empty: ConsoleText = "\(.blockBorderSymbol)"

        let footer: ConsoleText = "\(.blockEndSymbol) \(state.errorMessage ?? "", style: .error)"

        var rows: [ConsoleText]
        if state.filteredValues.isEmpty {
            rows = [
                empty,
                "\(.blockBorderSymbol)   \("Ничего не найдено", style: .error)",
            ]
        } else {
            let nonDataLineCount = 5
            let window = state.window(maxSize: (preferredSize?.rows ?? 10) - nonDataLineCount)
            rows = (window.minimum...window.maximum).map { offset in
                let selectable = state.filteredValues[offset]

                let isActive = offset == state.activeIndex
                let isSelected = state.selectedIds.contains(selectable.id)

                let activeMark: ConsoleText = isActive ? "\(.activeSymbol, style: .success)" : " "
                let selectionMark: ConsoleText = isSelected ? "\(.selectedSymbol, style: .success)" : "\(.unselectedSymbol)"

                let help: ConsoleText = selectable.help.map { "(\($0))".consoleText(.help) } ?? ""

                return "\(.blockBorderSymbol) \(activeMark) \(selectionMark) \(selectable.title) \(help)"
            }
            let dots: ConsoleText = "\(.blockBorderSymbol)   \(String(repeating: .dashSpacerSymbol, count: 3), style: .help)"
            let isAtTop = window.minimum == 0
            let isAtBottom = window.maximum == state.filteredValues.count - 1

            rows = [isAtTop ? empty : dots] + rows + [isAtBottom ? empty : dots]
        }

        return .init(
            lines: [header, search] + rows + [footer],
            cursorPosition: .init(row: 1, col: 1 + searchPrompt.description.count + state.search.count)
        )
    }

    private func renderFinished(state: SelectComponentState<Value>) -> ConsoleRender {
        let header: ConsoleText = "\(.blockStartSymbol, style: .success) \(state.title, style: .success)"
        let footer: ConsoleText = "\(.blockEndSymbol, style: .success)"
        let rows: [ConsoleText] = state.selectedIds
            .compactMap { id in
                state.valuesIndex[id]
            }
            .map { selectable in
                "\(.blockBorderSymbol, style: .success) \(selectable.title)"
            }

        return .init(
            lines: [header] + rows + [footer]
        )
    }
}
