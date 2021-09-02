import Foundation
import PathLib

public final class FileSystemEnumeratorFactoryImpl: FileSystemEnumeratorFactory {
    private let fileManager: FileManager
    
    public init(fileManager: FileManager) {
        self.fileManager = fileManager
    }
    
    public func contentEnumerator(forPath path: AbsolutePath, style: ContentEnumerationStyle) -> FileSystemEnumerator {
        switch style {
        case .deep:
            return DeepFileSystemEnumerator(fileManager: fileManager, path: path)
        case .shallow:
            return ShallowFileSystemEnumerator(fileManager: fileManager, path: path)
        }
    }
    
    public func glob(pattern: GlobPattern) -> FileSystemEnumerator {
        GlobFileSystemEnumerator(pattern: pattern)
    }
}
