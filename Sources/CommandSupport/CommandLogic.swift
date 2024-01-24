public protocol CommandLogic {
    func run() throws
}

extension CommandLogic {
    public func toAsync() -> AsyncCommandLogic {
        SyncCommandLogicWrapper(command: self)
    }
}

private final class SyncCommandLogicWrapper: AsyncCommandLogic {
    private let job: () throws -> ()
    
    init(command: CommandLogic) {
        job = command.run
    }
    
    func run() async throws {
        try job()
    }
}
