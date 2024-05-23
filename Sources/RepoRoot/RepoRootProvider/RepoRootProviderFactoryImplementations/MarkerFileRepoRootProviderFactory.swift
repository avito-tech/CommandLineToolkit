import FileSystem
import PathLib

public final class MarkerFileRepoRootProviderFactory: RepoRootProviderFactory {
    private let fileExistenceChecker: FileExistenceChecker
    private let markerFileName: String
    
    public init(
        fileExistenceChecker: FileExistenceChecker,
        markerFileName: String
    ) {
        self.fileExistenceChecker = fileExistenceChecker
        self.markerFileName = markerFileName
    }
    
    public func repoRootProvider(anyPathWithinRepo: AbsolutePath) -> RepoRootProvider {
        MarkerFileRepoRootProvider(
            fileExistenceChecker: fileExistenceChecker,
            markerFileName: markerFileName,
            anyPathWithinRepo: anyPathWithinRepo
        )
    }
}
