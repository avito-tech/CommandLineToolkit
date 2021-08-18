import Foundation

public final class CompoundCommandLogic: CommandLogic {
    private let commandLogics: [CommandLogic]
    
    public init(_ commandLogics: [CommandLogic]) {
        self.commandLogics = commandLogics
    }
    
    public func run() throws {
        try commandLogics.forEach {
            try $0.run()
        }
    }
}
