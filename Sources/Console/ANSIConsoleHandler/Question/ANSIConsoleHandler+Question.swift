extension ANSIConsoleHandler {
    /// Ask user a question
    /// - Parameters:
    ///   - title: question to ask
    ///   - defaultAnswer: default answer, yser can just hit enter
    /// - Returns: boolean answer
    public func question(
        title: String,
        defaultAnswer: Bool,
        file: StaticString,
        line: UInt
    ) async throws -> Bool {
        guard isAtTTY else {
            fatalError("Using question is only allowed at TTY", file: file, line: line)
        }
        guard isInteractive else {
            return nonInteractiveQuestion(title: title, defaultAnswer: defaultAnswer)
        }

        let component = QuestionComponent(state: .init(title: title, defaultAnswer: defaultAnswer))

        return try await run(component, file: file, line: line)
    }

    private func nonInteractiveQuestion(title: String, defaultAnswer: Bool = true) -> Bool {
        let indent = indentString()
        terminal.writeln(indent, "\(title) \(defaultAnswer ? "[Y]/n" : "y/[N]")")
        while true {
            terminal.write(indent, "> ")
            let input = readLine(strippingNewline: true) ?? (defaultAnswer ? "y" : "n")
            switch input {
            case "Y", "y":
                return true
            case "N", "n":
                return false
            default:
                terminal.writeln(indent, "Wrong input, try again")
                continue
            }
        }
    }
}
