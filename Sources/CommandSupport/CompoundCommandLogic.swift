/// Allows to chain execution of nested ``CommandLogic``'s
public final class CompoundCommandLogic: CommandLogic {
    private let commandLogics: [CommandLogic]

    public init(_ commandLogics: [CommandLogic]) {
        self.commandLogics = commandLogics
    }

    public func run() throws {
        for logic in commandLogics {
            try logic.run()
        }
    }
}
