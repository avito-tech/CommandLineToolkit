import PathLib
import Foundation

public protocol FilePropertiesProvider: FileExistenceChecker {
    func properties(path: AbsolutePath) -> FilePropertiesContainer
}

extension FilePropertiesProvider {
    public func existence(path: AbsolutePath) -> FileExistence {
        properties(path: path).existence
    }
}
