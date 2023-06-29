import Foundation

extension ANSIConsoleHandler {
    /// Select values from a list
    /// - Parameters:
    ///   - title: describes what user selects
    ///   - values: list of possible values
    ///   - options: possible selection options
    /// - Returns: array of selected values
    public func select<Value>(
        title: String,
        values: [Selectable<Value>],
        mode: SelectionMode,
        options: SelectionOptions,
        file: StaticString,
        line: UInt
    ) async throws -> [Value] {
        guard isAtTTY else {
            fatalError("Using select is only allowed at TTY", file: file, line: line)
        }
        guard isInteractive else {
            return try nonInteractiveSelect(title: title, values: values, options: options)
        }

        let component = SelectComponent(state: .init(
            title: title,
            values: values,
            mode: mode,
            options: options
        ))

        return try await run(component, file: file, line: line)
    }

    private func nonInteractiveSelect<Value>(
        title: String,
        values: [Selectable<Value>],
        options: SelectionOptions = .init()
    ) throws -> [Value] {
        let indent = indentString()
        terminal.writeln(indent, "\(title) (comma separated string)")
        for (offset, value) in values.enumerated() {
            terminal.writeln(indent, "\(offset): \(value.title) (\(value.help ?? ""))")
        }

        terminal.write(indent, "> ")

        let input = readLine(strippingNewline: true) ?? ""
        let selectedValues = input
            .components(separatedBy: ",")
            .compactMap(Int.init)
            .map { values[$0] }

        terminal.writeln(indent, "Selected: \(selectedValues.map(\.title).joined(separator: ", "))")

        return selectedValues.map(\.value)
    }
}
