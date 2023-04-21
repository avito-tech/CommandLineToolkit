/// Allows to run asynchronous commands
public protocol AsyncCommandLogic {
    func run() async throws
}
