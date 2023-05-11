import Foundation
import PathLib

public final class DeepFileSystemEnumerator: FileSystemEnumerator {
    private let path: AbsolutePath
    private let fileManager = FileManager()
    
    public struct CouldNotCreateEnumerator: Error, CustomStringConvertible {
        public let path: AbsolutePath
        public var description: String {
            "Could not create enumerator"
        }
    }
    
    public init(
        path: AbsolutePath
    ) {
        self.path = path
    }
    
    public func each(iterator: (AbsolutePath) throws -> ()) throws {
        guard let enumerator = fileManager.enumerator(at: path.fileUrl, includingPropertiesForKeys: nil) else {
            throw CouldNotCreateEnumerator(path: path)
        }
        
        for case let fileURL as URL in enumerator {
            let absolutePath = AbsolutePath(fileURL)
            try iterator(absolutePath)
        }
    }
}
