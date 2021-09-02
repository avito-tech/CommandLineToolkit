import ProcessController
import PathLib
import FileSystem

public final class GitRepoRootProviderFactory: RepoRootProviderFactory {
    private let processControllerProvider: ProcessControllerProvider
    private let pathToGit: AbsolutePath
    private let fileExistenceChecker: FileExistenceChecker
    
    public init(
        processControllerProvider: ProcessControllerProvider,
        pathToGit: AbsolutePath,
        fileExistenceChecker: FileExistenceChecker
    ) {
        self.processControllerProvider = processControllerProvider
        self.pathToGit = pathToGit
        self.fileExistenceChecker = fileExistenceChecker
    }
    
    public func repoRootProvider(
        anyPathWithinRepo: AbsolutePath
    ) -> RepoRootProvider {
        return GitRepoRootProvider(
            processControllerProvider: processControllerProvider,
            pathToGit: pathToGit,
            fileExistenceChecker: fileExistenceChecker,
            anyPathWithinRepo: anyPathWithinRepo
        )
    }
}
