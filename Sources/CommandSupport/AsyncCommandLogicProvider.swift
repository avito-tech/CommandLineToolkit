/// Provides command logic for async commands
public protocol AsyncCommandLogicProvider {
    func asyncCommandLogic() throws -> AsyncCommandLogic
}
