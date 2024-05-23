import PathLib
import FileSystem

public final class MarkerFileRepoRootProvider: RepoRootProvider {
    private let fileExistenceChecker: FileExistenceChecker
    private let markerFileName: String
    private let anyPathWithinRepo: AbsolutePath
    
    public init(
        fileExistenceChecker: FileExistenceChecker,
        markerFileName: String,
        anyPathWithinRepo: AbsolutePath
    ) {
        self.fileExistenceChecker = fileExistenceChecker
        self.markerFileName = markerFileName
        self.anyPathWithinRepo = anyPathWithinRepo
    }
    
    public func repoRoot() throws -> AbsolutePath {
        var workingPath = anyPathWithinRepo
        
        while true {
            let potentialRepoRootMarkerPath = workingPath.appending(markerFileName)
            
            if fileExistenceChecker.existence(path: potentialRepoRootMarkerPath).isFile {
                return workingPath
            }
            
            if workingPath.isRoot {
                throw RepoRootNotFoundError(path: anyPathWithinRepo)
            }
            
            workingPath = workingPath.removingLastComponent
        }
    }
}

private struct RepoRootNotFoundError: Error, CustomStringConvertible {
    let path: AbsolutePath
    var description: String {
        return "Did not find repo root while starting searching in path \(path)"
    }
}
