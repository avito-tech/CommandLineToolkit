extension ANSIConsoleHandler {
    public func input(
        title: String,
        defaultValue: String? = nil,
        file: StaticString,
        line: UInt
    ) async throws -> String {
        try Task.checkCancellation()

        guard isAtTTY else {
            fatalError("Using input is only allowed at TTY", file: file, line: line)
        }
        guard isInteractive else {
            return nonInteractiveInput(title: title, defaultValue: defaultValue)
        }
        let component = InputComponent(state: .init(
            title: title,
            defaultValue: defaultValue
        ))
        return try await run(component, file: file, line: line)
    }

    private func nonInteractiveInput(title: String, defaultValue: String? = nil) -> String {
        let indent = indentString()
        terminal.write(indent, title, defaultValue.map { " [\($0)]" } ?? "", "\n", indent, "> ")
        let value = readLine(strippingNewline: true) ?? ""
        if value.isEmpty {
            return defaultValue ?? value
        } else {
            return value
        }
    }
}
