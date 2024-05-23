import PathLib

public final class ClosureRepoRootProvider: RepoRootProvider {
    private let repoRootProvider: () throws -> AbsolutePath
    
    public init(repoRootProvider: @escaping () throws -> AbsolutePath) {
        self.repoRootProvider = repoRootProvider
    }
    
    public func repoRoot() throws -> AbsolutePath {
        try repoRootProvider()
    }
}
