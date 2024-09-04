import Foundation
import Logging
@testable import Console

@resultBuilder
enum TraceTreeBuilder {
    static func buildBlock(_ components: any ConsoleComponent...) -> [any ConsoleComponent] {
        components
    }
}

extension TraceComponent where Value == Void {
    static func normal(level: Logger.Level, result: Result<Void, Error>? = nil, @TraceTreeBuilder children: () -> [any ConsoleComponent] = { [] }) -> Self {
        self.init(level: level, options: [], result: result, children: children)
    }
    
    static func collapse(level: Logger.Level, result: Result<Void, Error>? = nil, @TraceTreeBuilder children: () -> [any ConsoleComponent] = { [] }) -> Self {
        self.init(level: level, options: .collapseFinished, result: result, children: children)
    }
    
    private convenience init(level: Logger.Level, options: TraceOptions, result: Result<Void, Error>? = nil, @TraceTreeBuilder children: () -> [any ConsoleComponent] = { [] }) {
        self.init(parent: nil, state: .init(
            level: level,
            name: "Test \(level) trace, options: \(options)",
            options: options,
            operationState: result.map(TraceOperationState.finished) ?? .started
        ))
        
        children().forEach { child in
            self.add(child: child)
        }
    }
}
