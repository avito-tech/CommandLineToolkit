import Foundation
import PathLib

public final class PathCopierImpl: PathCopier {
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
    
    public func copy(
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
        
        try fileManager.copyItem(
            at: source.fileUrl,
            to: destination.fileUrl
        )
    }
}
