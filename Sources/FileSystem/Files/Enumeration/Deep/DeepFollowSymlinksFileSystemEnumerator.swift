import Foundation
import PathLib

public final class DeepFollowSymlinksFileSystemEnumerator: FileSystemEnumerator {
    private let path: AbsolutePath
    private let fileManager: FileManager
    private let filePropertiesProvider: FilePropertiesProvider
    
    public enum EnumerationError: Error {
        case enumeratorFailure
    }
    
    public init(
        fileManager: FileManager,
        path: AbsolutePath,
        filePropertiesProvider: FilePropertiesProvider
    ) {
        self.fileManager = fileManager
        self.path = path
        self.filePropertiesProvider = filePropertiesProvider
    }
    
    public func each(iterator: (AbsolutePath) throws -> ()) throws {
        try ShallowFileSystemEnumerator(
            fileManager: fileManager,
            path: path
        ).each { [filePropertiesProvider, fileManager] path in
            try iterator(path)
            guard try filePropertiesProvider.isDirectory(
                path: path
            ) || filePropertiesProvider.isSymbolicLinkToDirectory(
                path: path
            ) else {
                return
            }
            try DeepFollowSymlinksFileSystemEnumerator(
                fileManager: fileManager,
                path: path,
                filePropertiesProvider: filePropertiesProvider
            ).each(iterator: iterator)
        }
    }
}
