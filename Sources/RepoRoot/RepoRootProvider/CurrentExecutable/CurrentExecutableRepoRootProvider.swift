import Environment
import PathLib

// When executable is insude repo or program is running from Xcode
// and sources are in repo
public final class CurrentExecutableRepoRootProvider: RepoRootProvider {
    private let repoRootProviderFactory: RepoRootProviderFactory
    private let currentExecutableProvider: CurrentExecutableProvider
    
    public init(
        repoRootProviderFactory: RepoRootProviderFactory,
        currentExecutableProvider: CurrentExecutableProvider
    ) {
        self.repoRootProviderFactory = repoRootProviderFactory
        self.currentExecutableProvider = currentExecutableProvider
    }
    
    public func repoRoot() throws -> AbsolutePath {
        let currentExecutablePath = try currentExecutableProvider.currentExecutablePath()
        
        do {
            // When executable is called from script and lays within repo
            return try repoRootProviderFactory.repoRoot(
                anyPathWithinRepo: currentExecutablePath
            )
        } catch {
            // When program is run in Xcode and sources are in repo
            return try repoRootProviderFactory.repoRoot(
                anyPathWithinRepo: #filePath
            )
        }
    }
}
