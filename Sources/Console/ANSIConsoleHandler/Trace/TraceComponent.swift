import Foundation
import Logging
import AtomicModels

final class TraceComponent<Value>: ConsoleComponent, ContainerConsoleComponent {
    typealias ComponentState = TraceComponentState<Value>

    @AtomicValue
    var parent: ContainerConsoleComponent?

    @AtomicValue
    var children: [any ConsoleComponent]
    
    @AtomicValue
    var state: ComponentState

    private let clock: TraceClock

    func add(child: any ConsoleComponent) {
        children.append(child)
        
        if let child = child as? ContainerConsoleComponent {
            child.parent = self
        }
    }

    init(
        parent: ContainerConsoleComponent?,
        state: ComponentState,
        children: [any ConsoleComponent] = [],
        clock: TraceClock
    ) {
        self.parent = parent
        self.state = state
        self.children = children
        self.clock = clock
    }

    var result: Result<Value, Error>? {
        state.operationState?.finished
    }
    
    var isVisible: Bool {
        let verbosity = ConsoleContext.current.verbositySettings
        
        if state.level >= verbosity.logLevel || isFailure || verbosity.verbose {
            return true
        }
        
        if state.options.contains(.collapseFinished) {
            return children.contains { child in
                child.isVisible && !child.canBeCollapsed(at: state.level)
            }
        } else {
            return children.contains { child in
                child.isVisible
            }
        }
    }
    
    func canBeCollapsed(at level: Logger.Level) -> Bool {
        let verbosity = ConsoleContext.current.verbositySettings
        
        if !isSuccess || verbosity.verbose || state.level > level {
            return false
        }
        
        return children.allSatisfy { child in
            child.canBeCollapsed(at: state.level)
        }
    }

    func updateOperationState(state operationState: TraceOperationState<Value>) {
        state.operationState = operationState

        switch operationState {
        case .started:
            state.startTime = clock.now
        case .finished:
            state.endTime = clock.now
        default:
            break
        }
    }

    func handle(event: ConsoleControlEvent) {
        for child in children where child.isUnfinished {
            child.handle(event: event)
        }

        switch event {
        case .tick:
            state.frame = (state.frame + 1) % 60
        case .inputChar, .inputEscapeSequence:
            break
        }
    }

    private func childrenRenderers(state: ComponentState) -> [AnyRenderer<Void>] {
        let result: [AnyRenderer<Void>]
        
        if state.options.contains(.collapseFinished) {
            result = children
                .filter { $0.isVisible && !$0.canBeCollapsed(at: state.level) || isFailure }
                .map { $0.typeErasedRenderer() }
        } else {
            result = children
                .filter { $0.isVisible || isFailure }
                .map { $0.typeErasedRenderer() }
        }
        
        return result
    }

    func renderer() -> some Renderer<Void> {
        let childrenRenderers = childrenRenderers(state: state)

        let progressOverride: Progress?
        if state.options.contains(.countSubtraces), isUnfinished {
            progressOverride = .discrete(
                current: children.lazy.filter(\.isFinished).count,
                total: children.count
            )
        } else {
            progressOverride = nil
        }

        return TraceComponentRenderer(clock: clock).withState(state: .init(
            childrenRenderers: childrenRenderers,
            progressOverride: progressOverride,
            traceState: state
        ))
    }
}
