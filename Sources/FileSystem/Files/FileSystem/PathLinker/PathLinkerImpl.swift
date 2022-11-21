import Foundation
import PathLib

public final class PathLinkerImpl: PathLinker {
    private let fileManager: FileManager
    private let destinationPreparer: DestinationPreparer
    
    init(
        fileManager: FileManager,
        pathDeleter: PathDeleter,
        directoryCreator: DirectoryCreator
    ) {
        self.fileManager = fileManager
        self.destinationPreparer = DestinationPreparer(
            pathDeleter: pathDeleter,
            directoryCreator: directoryCreator
        )
    }
    
    public func symLink(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool,
        ensureDirectoryExists: Bool
    ) throws {
        try destinationPreparer.prepareForModification(
            destination: source,
            prepareForOverwriting: overwrite,
            ensureDirectoryExists: ensureDirectoryExists
        )
        
        try fileManager.createSymbolicLink(
            atPath: source.asString,
            withDestinationPath: destination.asString
        )
    }
}
