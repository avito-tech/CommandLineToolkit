import Foundation
import PathLib

public final class ShallowFileSystemEnumerator: FileSystemEnumerator {
    private let path: AbsolutePath
    private let fileManager = FileManager()
    
    public init(
        path: AbsolutePath
    ) {
        self.path = path
    }
    
    public func each(iterator: (AbsolutePath) throws -> ()) throws {
        let contents = try fileManager.contentsOfDirectory(atPath: path.pathString)
        
        for element in contents {
            try iterator(path.appending(element))
        }
    }
}
