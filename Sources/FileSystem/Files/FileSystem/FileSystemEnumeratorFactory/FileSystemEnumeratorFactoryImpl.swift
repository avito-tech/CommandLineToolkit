import Foundation
import PathLib

public final class FileSystemEnumeratorFactoryImpl: FileSystemEnumeratorFactory, FileSystemEntrySequenceFactory {
    private let filePropertiesProvider: FilePropertiesProvider
    
    public init(
        filePropertiesProvider: FilePropertiesProvider
    ) {
        self.filePropertiesProvider = filePropertiesProvider
    }
    
    public func contentEnumerator(forPath path: AbsolutePath, style: ContentEnumerationStyle) -> FileSystemEnumerator {
        switch style {
        case .deep:
            return DeepFileSystemEnumerator(path: path)
        case .deepFollowSymlinks:
            return DeepFollowSymlinksFileSystemEnumerator(path: path, filePropertiesProvider: filePropertiesProvider)
        case .shallow:
            return ShallowFileSystemEnumerator(path: path)
        }
    }
    
    public func entries(
        at root: AbsolutePath,
        traversal: FileSystemTraversal,
        descendingInto: @escaping @Sendable (FileSystemEntry) -> Bool
    ) -> FileSystemEntrySequence {
        .local(at: root, traversal: traversal, descendingInto: descendingInto)
    }

    public func glob(pattern: GlobPattern) -> FileSystemEnumerator {
        GlobFileSystemEnumerator(pattern: pattern)
    }
}
