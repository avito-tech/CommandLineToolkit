import FileSystem
import Foundation
import PathLib

public class FakeFileSystemEnumerator: FileSystemEnumerator {
    public let path: AbsolutePath
    public var items = [AbsolutePath]()
    
    public init(path: AbsolutePath, items: [AbsolutePath] = []) {
        self.path = path
        self.items = items
    }
    
    public func each(iterator: (AbsolutePath) throws -> ()) throws {
        try items.forEach(iterator)
    }
}
