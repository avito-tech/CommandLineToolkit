import Foundation
import PathLib

public final class DefaultFileSystemPropertiesContainer: FileSystemPropertiesContainer {
    private let path: AbsolutePath
    public init(path: AbsolutePath) {
        self.path = path
    }
    
    public func systemFreeSize() throws -> Int64 {
        let attributes = try FileManager().attributesOfFileSystem(forPath: path.pathString)
        guard let value = attributes[.systemFreeSize], let number = value as? NSNumber else {
            throw FilePropertiesContainerError.emptyFileAttributeValue(path, .systemFreeSize)
        }
        return number.int64Value
    }
}
