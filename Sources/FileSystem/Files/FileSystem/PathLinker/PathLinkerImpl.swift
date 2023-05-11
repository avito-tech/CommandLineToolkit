import Foundation
import PathLib

public final class PathLinkerImpl: PathLinker {
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
