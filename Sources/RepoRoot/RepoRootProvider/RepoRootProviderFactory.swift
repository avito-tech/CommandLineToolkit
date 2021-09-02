import PathLib

public protocol RepoRootProviderFactory {
    func repoRootProvider(
        anyPathWithinRepo: AbsolutePath
    ) -> RepoRootProvider
}

extension RepoRootProviderFactory {
    public func repoRoot(
        anyPathWithinRepo: AbsolutePath
    ) throws -> AbsolutePath {
        try repoRootProvider(
            anyPathWithinRepo: anyPathWithinRepo
        ).repoRoot()
    }
}
