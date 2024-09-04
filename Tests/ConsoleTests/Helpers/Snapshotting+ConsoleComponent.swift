import SnapshotTesting
@testable import Console

extension Snapshotting where Value: ConsoleComponent, Format == String {
    static func consoleRaw(verbositySettings: ConsoleVerbositySettings) -> Snapshotting {
        SimplySnapshotting.lines.pullback { component in
            ConsoleContext.$current.withUpdated(key: \.verbositySettings, value: verbositySettings) {
                component
                    .renderer()
                    .render(preferredSize: nil)
                    .lines
                    .map { line in
                        line
                            .terminalStylize()
                            .replacingOccurrences(of: String.ESC, with: "^")
                    }
                    .joined(separator: "\n")
            }
        }
    }
    
    static func consoleText(verbositySettings: ConsoleVerbositySettings) -> Snapshotting {
        SimplySnapshotting.lines.pullback { component in
            ConsoleContext.$current.withUpdated(key: \.verbositySettings, value: verbositySettings) {
                component
                    .renderer()
                    .render(preferredSize: nil)
                    .lines
                    .map { line in
                        line.description
                    }
                    .joined(separator: "\n")
            }
        }
    }
}
