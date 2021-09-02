import PathLib

final class DestinationPreparer {
    private let pathDeleter: PathDeleter
    private let directoryCreator: DirectoryCreator
    
    init(
        pathDeleter: PathDeleter,
        directoryCreator: DirectoryCreator
    ) {
        self.pathDeleter = pathDeleter
        self.directoryCreator = directoryCreator
    }
    
    func prepareForModification(
        destination: AbsolutePath,
        prepareForOverwriting: Bool,
        ensureDirectoryExists: Bool
    ) throws {
        if prepareForOverwriting {
            try pathDeleter.delete(
                path: destination,
                ignoreMissing: true
            )
        }
        
        if ensureDirectoryExists {
            try directoryCreator.ensureDirectoryExists(
                path: destination.removingLastComponent
            )
        }
    }
}
