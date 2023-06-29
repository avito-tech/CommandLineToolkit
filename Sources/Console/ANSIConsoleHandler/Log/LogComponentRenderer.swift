import Logging
import Yams

struct LogComponentRenderer: Renderer {
    func render(state: LogComponentState, preferredSize: Size?) -> ConsoleRender {
        var originalLines = state.message.description.components(separatedBy: .newlines)

        let title: String = originalLines.first ?? ""
        let style: ConsoleStyle = .style(for: state.level)

        originalLines.removeFirst()

        let logLines = render(body: originalLines, style: style)

        let metadataLines: [ConsoleText]

        if state.metadata.isEmpty {
            metadataLines = []
        } else {
            let renderedMetadata = render(metadata: state.metadata)
                .components(separatedBy: "\n")
                .filter { $0.isEmpty == false }
            let longestLine = ([title] + originalLines + renderedMetadata).lazy.map(\.description.count).max() ?? 0
            metadataLines = [
                "\(.blockBorderJunction, style: style)\(String(repeating: .blockHorizontalBorder, count: longestLine + 1), style: style)"
            ] + render(body: renderedMetadata, style: style)
        }

        let bodyLines = logLines + metadataLines

        let header: ConsoleText = "\(bodyLines.isEmpty ? .noBlockSymbol : .blockStartSymbol, style: style) \(title, style: style)"

        if bodyLines.isEmpty {
            return .init(lines: [header])
        }

        return .init(
            lines: [header] + bodyLines + ["\(.blockEndSymbol, style: style)"]
        )
    }

    private func render(body: [String], style: ConsoleStyle) -> [ConsoleText] {
        body.map { "\(.blockBorderSymbol, style: style) \($0, style: style)" }
    }

    private func render(metadata: Logger.Metadata) -> String {
        let yaml = try? dump(
            object: metadata.mapValues(\.foundationObject),
            allowUnicode: true,
            sortKeys: true
        )

        return yaml ?? ""
    }
}

extension ConsoleStyle {
    static func style(for level: Logger.Level) -> Self {
        switch level {
        case .trace, .debug:
            return .plain
        case .info:
            return .info
        case .notice:
            return .notice
        case .warning:
            return .warning
        case .error, .critical:
            return .error
        }
    }
}

private extension Logger.MetadataValue {
    var foundationObject: Any {
        switch self {
        case .string(let string):
            return string
        case .stringConvertible(let customStringConvertible):
            return customStringConvertible.description
        case .dictionary(let metadata):
            return metadata.mapValues(\.foundationObject)
        case .array(let array):
            return array.map(\.foundationObject)
        }
    }
}
