/// Allows to chain execution of nested ``AsyncCommandLogic``'s
public final class CompoundAsyncCommandLogic: AsyncCommandLogic {
    private let commandLogics: [AsyncCommandLogic]

    public init(_ commandLogics: [AsyncCommandLogic]) {
        self.commandLogics = commandLogics
    }

    public func run() async throws {
        for logic in commandLogics {
            try await logic.run()
        }
    }
}
