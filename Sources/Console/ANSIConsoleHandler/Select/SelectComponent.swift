import Foundation
import Logging
import AtomicModels

final class SelectComponent<Value>: ConsoleComponent {
    @AtomicValue
    var state: SelectComponentState<Value>

    init(state: SelectComponentState<Value>) {
        self.state = state
    }

    var result: Result<[Selectable<Value>], Error>? {
        switch state.result {
        case nil:
            return nil
        case .cancelled:
            return .failure(CancellationError())
        case let .selected(values):
            return .success(values)
        }
    }

    var isVisible: Bool { true }

    func canBeCollapsed(at level: Logger.Level) -> Bool {
        false
    }
    
    func handle(event: ConsoleControlEvent) {
        switch event {
        case .inputChar(.enter):
            switch state.mode {
            case .single where state.selectedIds.isEmpty:
                state.errorMessage = "Нужно что нибудь выбрать"
            case .single:
                state.confirm()
            case let .multiple(min, max):
                guard min <= state.selectedIds.count else {
                    state.errorMessage = "Выбери как минимум \(min)"
                    break
                }
                guard state.selectedIds.count <= max else {
                    state.errorMessage = "Можно выбрать максимум \(max)"
                    break
                }
                state.confirm()
            }
        case .inputChar(.del):
            if !state.search.isEmpty {
                state.search.removeLast()
            }
        case .inputChar(.tab):
            break
        case .inputChar(.space):
            switch state.mode {
            case .single:
                break
            case let .multiple(_, max):
                if state.filteredValues.isEmpty {
                    break
                }
                let value = state.filteredValues[state.activeIndex]

                if let index = state.selectedIds.firstIndex(of: value.id) {
                    state.selectedIds.remove(at: index)
                } else if state.selectedIds.count < max {
                    state.selectedIds.append(value.id)
                }
            }
        case let .inputChar(char):
            state.search.append(char)
        case .inputEscapeSequence(.up, [.shift]):
            state.moveUp(count: state.options.quickMoveLines)
        case .inputEscapeSequence(.up, _):
            state.moveUp()
        case .inputEscapeSequence(.down, [.shift]):
            state.moveDown(count: state.options.quickMoveLines)
        case .inputEscapeSequence(.down, _):
            state.moveDown()
        case .inputEscapeSequence, .tick:
            break
        }
        if Task.isCancelled {
            state.cancel()
        }
    }

    func renderer() -> some Renderer<Void> {
        SelectComponentRenderer()
            .withCache()
            .withState(state: state)
    }
}
