import Foundation
import PathLib

public final class DirectoryCreatorImpl: DirectoryCreator {
    private let fileManager = FileManager()
    private let filePropertiesProvider: FilePropertiesProvider
    
    public init(
        filePropertiesProvider: FilePropertiesProvider
    ) {
        self.filePropertiesProvider = filePropertiesProvider
    }
    
    public struct DirectoryCreatorError: LocalizedError {
        let errorDescription: String
    }
    
    public func createDirectory(
        path: AbsolutePath,
        withIntermediateDirectories: Bool
    ) throws {
        let existence = filePropertiesProvider.existence(path: path)
        
        if existence.exists {
            if existence.isDirectory {
                // Already exists.
            } else {
                throw DirectoryCreatorError(
                    errorDescription: "Expected a directory, but found a file at path: \(path)"
                )
            }
        } else {
            try fileManager.createDirectory(
                atPath: path.pathString,
                withIntermediateDirectories: withIntermediateDirectories
            )
        }
    }
}
