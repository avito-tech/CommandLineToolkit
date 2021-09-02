import Foundation
import PathLib

public final class DirectoryCreatorImpl: DirectoryCreator {
    private let fileManager: FileManager
    private let filePropertiesProvider: FilePropertiesProvider
    
    public init(
        fileManager: FileManager,
        filePropertiesProvider: FilePropertiesProvider
    ) {
        self.fileManager = fileManager
        self.filePropertiesProvider = filePropertiesProvider
    }
    
    public func createDirectory(
        path: AbsolutePath,
        withIntermediateDirectories: Bool,
        ignoreExisting: Bool
    ) throws {
        struct DirectoryCreatorError: LocalizedError {
            let errorDescription: String?
        }

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
