import Foundation
import Logging

final actor TraceComponent<Value>: ConsoleComponent, ContainerConsoleComponent {
    let parent: ContainerConsoleComponent?
    var state: TraceComponentState<Value>

    var children: [any ConsoleComponent] {
        state.children
    }

    func add(child: any ConsoleComponent) {
        state.children.append(child)
    }

    init(
        parent: ContainerConsoleComponent?,
        state: TraceComponentState<Value>
    ) {
        self.parent = parent
        self.state = state
    }

    var result: Result<Value, Error>? {
        state.operationState?.finished
    }

    var canBeCollapsed: Bool {
        get async {
            guard case .finished = state.operationState, !state.verbose else {
                return false
            }

            var result = true
            for child in children {
                let canBeCollapsed = await child.canBeCollapsed
                result = result && canBeCollapsed
            }

            return result
        }
    }

    func updateOperationState(state operationState: TraceOperationState<Value>) {
        state.operationState = operationState

        switch operationState {
        case .started:
            state.startTime = CFAbsoluteTimeGetCurrent()
        case .finished:
            state.endTime = CFAbsoluteTimeGetCurrent()
        default:
            break
        }
    }

    func handle(event: ConsoleControlEvent) async {
        for child in children where await child.isUnfinished {
            await child.handle(event: event)
        }

        switch event {
        case .tick:
            state.frame = (state.frame + 1) % 60
        case .inputChar, .inputEscapeSequence:
            break
        }
    }

    private func childrenRenderers(state: TraceComponentState<Value>) async -> [AnyRenderer<Void>] {
        var result: [AnyRenderer<Void>] = []
        for child in children where await child.shouldRender(mode: state.mode) {
            await result.append(child.typeErasedRenderer())
        }
        return result
    }

    func renderer() async -> some Renderer<Void> {
        let childrenRenderers = await childrenRenderers(state: state)

        let progressOverride: Progress?
        switch state.mode {
        case .verbose, .collapseFinished:
            progressOverride = nil
        case .countSubtraces where state.operationState?.finished != nil:
            progressOverride = nil
        case .countSubtraces:
            var finishedChildren: Int = 0

            for child in children {
                if await child.isFinished {
                    finishedChildren += 1
                }
            }

            progressOverride = .discrete(current: finishedChildren, total: children.count)
        }

        return TraceComponentRenderer().withState(state: .init(
            childrenRenderers: childrenRenderers,
            progressOverride: progressOverride,
            traceState: state
        ))
    }

    func getContainerDepth() -> Int {
        var depth: Int = 0
        var activeContainer: ContainerConsoleComponent? = self
        while activeContainer != nil {
            activeContainer = activeContainer?.parent
            depth += 1
        }
        return depth
    }
}

private extension ConsoleComponent {
    func shouldRender(mode: TraceMode) async -> Bool {
        switch mode {
        case .verbose:
            return true
        case .collapseFinished:
            let isFinished = await isFinished
            let canBeCollapsed = await canBeCollapsed

            return !(isFinished && canBeCollapsed)
        case .countSubtraces:
            switch await result {
            case .failure:
                return true
            case .success:
                return !(await canBeCollapsed)
            case .none:
                return false
            }
        }
    }
}
