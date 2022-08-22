import Foundation
import PathLib

public protocol FileSystem:
    FileSystemEnumeratorFactory,
    DirectoryCreator,
    FileCreator,
    PathCopier,
    PathMover,
    PathDeleter,
    FilePropertiesProvider,
    FileSystemPropertiesProvider,
    CommonlyUsedPathsProviderFactory,
    FileToucher
{
}

extension FileSystem {
    public func copy(
        contentsOfDirectory sourcePath: AbsolutePath,
        destinationDirectory destinationPath: AbsolutePath,
        overwrite: Bool = true,
        ensureDirectoryExists: Bool = true
    ) throws {
        if ensureDirectoryExists {
            try self.ensureDirectoryExists(path: destinationPath)
        }
        
        try contentEnumerator(forPath: sourcePath, style: .shallow).each { path in
            try copy(
                source: path,
                destination: destinationPath.appending(path.lastComponent),
                overwrite: overwrite,
                ensureDirectoryExists: false
            )
        }
    }
    
    private func deleteIfExists(path: AbsolutePath) throws {
        try delete(path: path)
    }
}
