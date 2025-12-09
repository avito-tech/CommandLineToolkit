import PathLib
import Foundation

public final class FileCreatorImpl: FileCreator {
    public struct FileCreatorError: Error, CustomStringConvertible {
        public let path: AbsolutePath
        public var description: String {
            "Couldn't create or overwrite an existing file at: \(path)"
        }
    }
    
    private let fileManager = FileManager()
    
    public init() {
    }
    
    public func createFile(path: AbsolutePath, data: Data?) throws {
        if !fileManager.createFile(atPath: path.pathString, contents: data) {
            throw FileCreatorError(path: path)
        }
    }
    
    public func createExucatableFile(path: AbsolutePath, data: Data?) throws {
        if !fileManager.createFile(
            atPath: path.pathString,
            contents: data,
            attributes: [.posixPermissions: 0o755]
        ) {
            throw FileCreatorError(path: path)
        }
    }
}
