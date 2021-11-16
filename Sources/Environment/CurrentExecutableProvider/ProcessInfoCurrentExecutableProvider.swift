import Foundation
import CLTExtensions
import PathLib

public final class ProcessInfoCurrentExecutableProvider: CurrentExecutableProvider {
    private let processInfo: ProcessInfo
    
    public init(processInfo: ProcessInfo) {
        self.processInfo = processInfo
    }
    
    public func currentExecutablePath() throws -> AbsolutePath {
        let path = try processInfo.arguments.first.unwrapOrThrow(
            message: "processInfo's arguments list is empty"
        )
        
        if AbsolutePath.isAbsolute(path: path) {
            return AbsolutePath(path)
        } else {
            return AbsolutePath(FileManager().currentDirectoryPath).appending(
                relativePath: RelativePath(path)
            )
        }
    }
}
