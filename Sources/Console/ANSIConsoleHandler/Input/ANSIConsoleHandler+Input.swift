extension ANSIConsoleHandler {
    public func input(
        id: String?,
        title: String,
        defaultValue: String? = nil,
        help: String?,
        file: StaticString,
        line: UInt
    ) async throws -> String {
        try Task.checkCancellation()

        guard isAtTTY else {
            fatalError("Using input is only allowed at TTY", file: file, line: line)
        }
        guard isInteractive else {
            return nonInteractiveInput(title: title, defaultValue: defaultValue, help: help)
        }
        let component = InputComponent(state: .init(
            title: title,
            defaultValue: defaultValue,
            help: help
        ))
        return try await run(component, file: file, line: line)
    }

    private func nonInteractiveInput(title: String, defaultValue: String? = nil, help: String?) -> String {
        let indent = indentString()
        output.writeln(indent, title, defaultValue.map { " [\($0)]" } ?? "")
        if let help {
            output.writeln(indent, help)
        }
        output.write(indent, "> ")
        let value = readLine(strippingNewline: true) ?? ""
        if value.isEmpty {
            return defaultValue ?? value
        } else {
            return value
        }
    }
}
