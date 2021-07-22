import Foundation

public final class SAPCompoundCommandLogic: SAPCommandLogic {
    private let commandLogics: [SAPCommandLogic]
    
    public init(_ commandLogics: [SAPCommandLogic]) {
        self.commandLogics = commandLogics
    }
    
    public func run() throws {
        try commandLogics.forEach {
            try $0.run()
        }
    }
}
