import PathLib
import Foundation

public final class FileCreatorImpl: FileCreator {
    private enum FileCreatorError: Error {
        case failedToCreateFile(AbsolutePath)
    }
    
    private let fileManager: FileManager
    
    public init(fileManager: FileManager) {
        self.fileManager = fileManager
    }
    
    public func createFile(path: AbsolutePath, data: Data?) throws {
        if !fileManager.createFile(atPath: path.pathString, contents: data) {
            throw FileCreatorError.failedToCreateFile(path)
        }
    }
}
