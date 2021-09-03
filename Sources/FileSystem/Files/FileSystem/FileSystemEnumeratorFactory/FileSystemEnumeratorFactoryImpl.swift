import Foundation
import PathLib

public final class FileSystemEnumeratorFactoryImpl: FileSystemEnumeratorFactory {
    private let fileManager: FileManager
    private let filePropertiesProvider: FilePropertiesProvider
    
    public init(
        fileManager: FileManager,
        filePropertiesProvider: FilePropertiesProvider
    ) {
        self.fileManager = fileManager
        self.filePropertiesProvider = filePropertiesProvider
    }
    
    public func contentEnumerator(forPath path: AbsolutePath, style: ContentEnumerationStyle) -> FileSystemEnumerator {
        switch style {
        case .deep:
            return DeepFileSystemEnumerator(fileManager: fileManager, path: path)
        case .deepFollowSymlinks:
            return DeepFollowSymlinksFileSystemEnumerator(fileManager: fileManager, path: path, filePropertiesProvider: filePropertiesProvider)
        case .shallow:
            return ShallowFileSystemEnumerator(fileManager: fileManager, path: path)
        }
    }
    
    public func glob(pattern: GlobPattern) -> FileSystemEnumerator {
        GlobFileSystemEnumerator(pattern: pattern)
    }
}
