import Foundation
import ProcessController
import PathLib
import FileSystem
import String

public final class GitRepoRootProvider: RepoRootProvider {
    private let processControllerProvider: ProcessControllerProvider
    private let pathToGit: AbsolutePath
    private let fileExistenceChecker: FileExistenceChecker
    private let anyPathWithinRepo: AbsolutePath
    
    public init(
        processControllerProvider: ProcessControllerProvider,
        pathToGit: AbsolutePath,
        fileExistenceChecker: FileExistenceChecker,
        anyPathWithinRepo: AbsolutePath
    ) {
        self.processControllerProvider = processControllerProvider
        self.pathToGit = pathToGit
        self.fileExistenceChecker = fileExistenceChecker
        self.anyPathWithinRepo = anyPathWithinRepo
    }
    
    public func repoRoot() throws -> AbsolutePath {
        try AbsolutePath(gitRevParseShowTopLevel())
    }
    
    private func anyDirectoryPathWithinRepo() -> AbsolutePath {
        if fileExistenceChecker.existence(path: anyPathWithinRepo).isDirectory {
            return anyPathWithinRepo
        } else {
            return anyPathWithinRepo.removingLastComponent
        }
    }
    
    private func gitRevParseShowTopLevel() throws -> String {
        let processController = try processControllerProvider.createProcessController(
            subprocess: Subprocess(
                arguments: [pathToGit, "rev-parse", "--show-toplevel"],
                environment: [:],
                automaticManagement: .noManagement,
                workingDirectory: anyDirectoryPathWithinRepo()
            )
        )
        
        var stdout = Data()
        processController.onStdout { _, data, _ in stdout += data }
        
        try processController.startAndWaitForSuccessfulTermination()
        
        return try String(utf8Data: stdout).trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        )
    }
}
