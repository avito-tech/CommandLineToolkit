import Environment
import PathLib
import FileSystem

// When executable is inside repo or program is running from Xcode
// and sources are in repo
public final class WorkdirRepoRootProvider: RepoRootProvider {
    private let repoRootProviderFactory: RepoRootProviderFactory
    private let fileSystem: FileSystem

    public init(
        repoRootProviderFactory: RepoRootProviderFactory,
        fileSystem: FileSystem
    ) {
        self.repoRootProviderFactory = repoRootProviderFactory
        self.fileSystem = fileSystem
    }

    public func repoRoot() throws -> AbsolutePath {
        try repoRootProviderFactory.repoRoot(
            anyPathWithinRepo: fileSystem.currentWorkingDirectory
        )
    }
}
