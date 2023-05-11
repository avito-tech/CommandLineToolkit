import Foundation
import PathLib

public final class DeepFollowSymlinksFileSystemEnumerator: FileSystemEnumerator {
    private let path: AbsolutePath
    private let filePropertiesProvider: FilePropertiesProvider
    
    public init(
        path: AbsolutePath,
        filePropertiesProvider: FilePropertiesProvider
    ) {
        self.path = path
        self.filePropertiesProvider = filePropertiesProvider
    }
    
    public func each(iterator: (AbsolutePath) throws -> ()) throws {
        try ShallowFileSystemEnumerator(
            path: path
        ).each { [filePropertiesProvider] path in
            try iterator(path)
            
            let properties = filePropertiesProvider.properties(path: path)
            
            guard try properties.isDirectory || properties.isSymbolicLinkToDirectory else {
                return
            }
            try DeepFollowSymlinksFileSystemEnumerator(
                path: path,
                filePropertiesProvider: filePropertiesProvider
            ).each(iterator: iterator)
        }
    }
}
