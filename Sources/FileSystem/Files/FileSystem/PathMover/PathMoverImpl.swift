import Foundation
import PathLib

public final class PathMoverImpl: PathMover {
    private let fileManager = FileManager()
    private let destinationPreparer: DestinationPreparer
    
    public init(
        pathDeleter: PathDeleter,
        directoryCreator: DirectoryCreator
    ) {
        self.destinationPreparer = DestinationPreparer(
            pathDeleter: pathDeleter,
            directoryCreator: directoryCreator
        )
    }
    
    public func move(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool,
        ensureDirectoryExists: Bool
    ) throws {
        try destinationPreparer.prepareForModification(
            destination: destination,
            prepareForOverwriting: overwrite,
            ensureDirectoryExists: ensureDirectoryExists
        )
        
        try fileManager.moveItem(at: source.fileUrl, to: destination.fileUrl)
    }
}
