public final class NoopTeamcityMessaging: TeamcityMessaging {
    public init() {
    }
    
    public func block<T>(name: String, flowId: String?, body: () throws -> T) rethrows -> T {
        try body()
    }
    
    public func block<T>(name: String, flowId: String?, body: () async throws -> T) async rethrows -> T {
        try await body()
    }
}
