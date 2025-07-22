import Foundation

public final actor ConsoleActionStorage {
    @TaskLocal public static var current: ConsoleActionStorage = .init()

    public enum Action {
        case input(id: String, result: Result<String, Error>)
        case question(id: String, result: Result<Bool, Error>)
        case select(id: String, result: Result<[String], Error>)
        case trace(
            id: String,
            start: TraceClock.Instant,
            duration: TraceClock.Duration,
            actions: [Action],
            metadata: [String: TraceMetadataValue],
            result: Result<Void, Error>
        )
    }

    public private(set) var actions: [Action] = []

    func add(action: Action) {
        actions.append(action)
    }
}
