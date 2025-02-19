import Foundation

public struct Selectable<Value>: Hashable {
    let id: UUID = .init()
    public let title: String
    public let help: String?
    public let value: Value

    public init(title: String, help: String? = nil, value: Value) {
        self.title = title
        self.help = help
        self.value = value
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

public enum SelectionMode: Hashable {
    case single
    case multiple(min: Int, max: Int)
}

public struct SelectionOptions: Hashable {
    public var quickMoveLines: Int
    public var maxListLength: Int

    public init(
        quickMoveLines: Int = 5,
        maxListLength: Int = .max
    ) {
        self.quickMoveLines = quickMoveLines
        self.maxListLength = maxListLength
    }
}

struct SelectWindow: Hashable {
    var minimum: Int
    var maximum: Int
}

struct SelectComponentState<Value>: Hashable {
    enum SelectionResult: Hashable {
        case cancelled
        case selected(values: [Selectable<Value>])
    }

    let title: String
    let values: [Selectable<Value>]
    let valuesIndex: [UUID: Selectable<Value>]
    let mode: SelectionMode
    let options: SelectionOptions
    var selectedIds: [UUID] = []

    var errorMessage: String?

    var filteredValues: [Selectable<Value>]

    var search: String = "" {
        didSet {
            if search.isEmpty {
                filteredValues = values
            } else {
                filteredValues = values.filter { selectable in
                    selectable.title.lowercased().contains(search.lowercased())
                }
            }
            activeIndex = 0
            window = .init(minimum: 0, maximum: min(filteredValues.count - 1, options.maxListLength))
        }
    }
    var isSearchVisible: Bool {
        !search.isEmpty
    }

    private(set) var result: SelectionResult?
    
    var isFinished: Bool {
        result != nil
    }

    private(set) var activeIndex: Int = 0 {
        didSet {
            if mode == .single {
                selectedIds = filteredValues.isEmpty ? [] : [filteredValues[activeIndex].id]
            }
        }
    }
    private(set) var window: SelectWindow

    private let windowMoveThreshold: Int = 3

    init(
        title: String,
        values: [Selectable<Value>],
        mode: SelectionMode,
        options: SelectionOptions = .init()
    ) {
        self.title = title
        self.values = values
        self.mode = mode
        self.options = options
        self.window = .init(minimum: 0, maximum: min(values.count - 1, options.maxListLength))
        self.filteredValues = values
        self.valuesIndex = values.reduce(into: [:]) { partialResult, value in
            partialResult[value.id] = value
        }
        if mode == .single {
            selectedIds = filteredValues.isEmpty ? [] : [filteredValues[activeIndex].id]
        }
    }

    func window(maxSize: Int) -> SelectWindow {
        let halfWindowSize = maxSize / 2
        let expectedMinimum = max(0, activeIndex - halfWindowSize)
        let expectedMaximum = min(filteredValues.count - 1, activeIndex + halfWindowSize)
        return .init(
            minimum: max(0, min(expectedMinimum, expectedMaximum - (halfWindowSize + halfWindowSize))),
            maximum: min(filteredValues.count - 1, max(expectedMaximum, expectedMinimum + (halfWindowSize + halfWindowSize)))
        )
    }

    mutating func cancel() {
        result = .cancelled
    }

    mutating func confirm() {
        result = .selected(values: selectedIds.compactMap { valuesIndex[$0] })
    }

    mutating func moveUp(count: Int = 1) {
        activeIndex = max(activeIndex - count, 0)
        if activeIndex < window.minimum + windowMoveThreshold {
            window.minimum = max(0, activeIndex - windowMoveThreshold)
            window.maximum = min(filteredValues.count - 1, window.minimum + options.maxListLength)
        }
    }

    mutating func moveDown(count: Int = 1) {
        activeIndex = min(activeIndex + count, filteredValues.count - 1)
        if activeIndex > window.maximum - windowMoveThreshold {
            window.maximum = min(filteredValues.count - 1, activeIndex + windowMoveThreshold)
            window.minimum = max(0, window.maximum - options.maxListLength)
        }
    }
}
