import PathLib

public final class CachingRepoRootProviderFactory: RepoRootProviderFactory {
    private let repoRootProviderFactory: RepoRootProviderFactory
    
    public init(repoRootProviderFactory: RepoRootProviderFactory) {
        self.repoRootProviderFactory = repoRootProviderFactory
    }
    
    public func repoRootProvider(
        anyPathWithinRepo: AbsolutePath
    ) -> RepoRootProvider {
        return CachingRepoRootProvider(
            repoRootProvider: repoRootProviderFactory.repoRootProvider(
                anyPathWithinRepo: anyPathWithinRepo
            )
        )
    }
}
