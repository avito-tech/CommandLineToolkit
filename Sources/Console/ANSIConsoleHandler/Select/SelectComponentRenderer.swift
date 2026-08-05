struct SelectComponentRenderer<Value>: Renderer {
    func render(state: SelectComponentState<Value>, preferredSize: Size?) -> ConsoleRender {
        switch state.result {
        case nil:
            return renderInProgress(state: state, preferredSize: preferredSize)
        case .cancelled:
            return renderCancelled(state: state, preferredSize: preferredSize)
        case let .selected(values):
            return renderFinished(state: state, values: values, preferredSize: preferredSize)
        }
    }

    private func renderCancelled(state: SelectComponentState<Value>, preferredSize: Size?) -> ConsoleRender {
        return .init(
            lines: titleLines(state.title, preferredSize: preferredSize, style: .error) + [
                "\(.blockEndSymbol, style: .error) \(.cancelSymbol, style: .error)"
            ]
        )
    }

    private func renderInProgress(state: SelectComponentState<Value>, preferredSize: Size?) -> ConsoleRender {
        let selectionHelp: String
        var controlsHelps: [String] = ["[Space] — выбрать", "[Enter] — подтвердить"]

        switch state.mode {
        case .single:
            selectionHelp = "Выберите один вариант."
            controlsHelps = ["[Enter] — подтвердить"]
        case .multiple(_, .max):
            selectionHelp = "Выберите несколько вариантов."
        case let .multiple(_, max):
            selectionHelp = "Выберите несколько вариантов [\(state.selectedIds.count)/\(max)]."
        }

        if state.filteredValues.count > 10 {
            controlsHelps += ["[Shift] — быстро прокрутить"]
        }
        let controlsHelp = controlsHelps.joined(separator: ", ")

        let width = contentWidth(preferredSize)
        let headers = titleLines(state.title, preferredSize: preferredSize, style: .headerTitle)
        let help = (selectionHelp + " \(controlsHelp).")
            .wrapped(to: width)
            .map { "\(.blockBorderSymbol) \($0, style: .help)" as ConsoleText }
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
            let nonDataLineCount = 6 + headers.count + help.count
            let window = rowLimitedWindow(
                for: state,
                maximumRows: max(1, (preferredSize?.rows ?? 10) - nonDataLineCount),
                contentWidth: width
            )
            rows = (window.minimum...window.maximum).flatMap { offset in
                let selectable = state.filteredValues[offset]

                let isActive = offset == state.activeIndex
                let isSelected = state.selectedIds.contains(selectable.id)

                let activeMark: ConsoleText = isActive ? "\(.activeSymbol, style: .success)" : " "
                let selectionMark: ConsoleText = isSelected ? "\(.selectedSymbol, style: .success)" : "\(.unselectedSymbol)"

                let prefix: ConsoleText = "\(.blockBorderSymbol) \(activeMark) \(selectionMark) "
                let continuationPrefix: ConsoleText = "\(.blockBorderSymbol)     "
                let content = selectable.title + (selectable.help.map { " (\($0))" } ?? "")
                return content
                    .wrapped(to: max(1, width - prefix.description.count))
                    .enumerated()
                    .map { lineOffset, line in
                        "\(lineOffset == 0 ? prefix : continuationPrefix)\(line)" as ConsoleText
                    }
            }
            let dots: ConsoleText = "\(.blockBorderSymbol)   \(String(repeating: .dashSpacerSymbol, count: 3), style: .help)"
            let isAtTop = window.minimum == 0
            let isAtBottom = window.maximum == state.filteredValues.count - 1

            rows = [isAtTop ? empty : dots] + rows + [isAtBottom ? empty : dots]
        }

        return .init(
            lines: headers + help + [search] + rows + [footer],
            cursorPosition: .init(row: headers.count + help.count, col: 1 + searchPrompt.description.count + state.search.count)
        )
    }

    private func renderFinished(state: SelectComponentState<Value>, values: [Selectable<Value>], preferredSize: Size?) -> ConsoleRender {
        let headers = titleLines(state.title, preferredSize: preferredSize, style: .success)
        let footer: ConsoleText = "\(.blockEndSymbol, style: .success)"
        let rows: [ConsoleText] = values.map { selectable in
            "\(.blockBorderSymbol, style: .success) \(selectable.title)"
        }

        return .init(
            lines: headers + rows + [footer]
        )
    }

    private func titleLines(
        _ title: String,
        preferredSize: Size?,
        style: ConsoleStyle
    ) -> [ConsoleText] {
        title.wrapped(to: contentWidth(preferredSize)).enumerated().map { offset, line in
            "\(offset == 0 ? .blockStartSymbol : .blockBorderSymbol, style: style) \(line, style: style)"
        }
    }

    private func contentWidth(_ preferredSize: Size?) -> Int {
        preferredSize.map { max(1, $0.cols - 2) } ?? .max
    }

    private func rowLimitedWindow(
        for state: SelectComponentState<Value>,
        maximumRows: Int,
        contentWidth: Int
    ) -> SelectWindow {
        let maximumValueWidth = max(1, contentWidth - selectionPrefixLength)
        func rowCount(for selectable: Selectable<Value>) -> Int {
            let content = selectable.title + (selectable.help.map { " (\($0))" } ?? "")
            return content.wrapped(to: maximumValueWidth).count
        }

        var minimum = state.activeIndex
        var maximum = state.activeIndex
        var usedRows = rowCount(for: state.filteredValues[state.activeIndex])
        var preferPrevious = true

        while usedRows < maximumRows {
            let previous = minimum > 0 ? minimum - 1 : nil
            let next = maximum < state.filteredValues.count - 1 ? maximum + 1 : nil
            let candidates = preferPrevious ? [previous, next] : [next, previous]
            guard let index = candidates.compactMap({ $0 }).first(where: {
                usedRows + rowCount(for: state.filteredValues[$0]) <= maximumRows
            }) else {
                break
            }

            usedRows += rowCount(for: state.filteredValues[index])
            if index < minimum {
                minimum = index
            } else {
                maximum = index
            }
            preferPrevious.toggle()
        }

        return .init(minimum: minimum, maximum: maximum)
    }

    private var selectionPrefixLength: Int {
        let prefix: ConsoleText = "\(.blockBorderSymbol) \(.activeSymbol) \(.unselectedSymbol) "
        return prefix.description.count
    }
}
