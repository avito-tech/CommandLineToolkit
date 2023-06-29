import Foundation
import Logging

extension ANSIConsoleHandler {
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        let state = LogComponentState(level: level, message: message, metadata: metadata, source: source, file: file, function: function, line: line)

        guard isInteractive else {
            return nonInteractiveLog(state: state)
        }

        let component = LogComponent(state: state)
        if let activeContainer = ConsoleContext.current.activeContainer {
            runBlocking {
                await activeContainer.add(child: component)
            }
        } else {
            renderNonInteractive(component: component.renderer().render(preferredSize: nil))
        }
    }

    private func nonInteractiveLog(state: LogComponentState) {
        let indent = indentString()

        let component = LogComponent(state: state)

        let renderedComponent = component.renderer().render(preferredSize: nil)

        renderNonInteractive(component: .init(lines: renderedComponent.lines.map { text in
            "\(indent)\(text)"
        }))
    }

    func getContainerDepth() -> Int {
        var depth: Int = 0
        var activeContainer = ConsoleContext.current.activeContainer
        while activeContainer != nil {
            activeContainer = activeContainer?.parent
            depth += 1
        }
        return depth
    }

    func indentString() -> String {
        String(repeating: "  ", count: getContainerDepth())
    }
}
