import PathLib
import Foundation

public final class PathDeleterImpl: PathDeleter {
    private let fileManager = FileManager()
    private let filePropertiesProvider: FilePropertiesProvider
    
    public init(
        filePropertiesProvider: FilePropertiesProvider
    ) {
        self.filePropertiesProvider = filePropertiesProvider
    }
    
    public func delete(path: AbsolutePath, ignoreMissing: Bool) throws {
        if ignoreMissing {
            if filePropertiesProvider.exists(path: path) {
                try delete(path: path)
            } else {
                // ignore
            }
        } else {
            try delete(path: path)
        }
    }
    
    private func delete(path: AbsolutePath) throws {
        try fileManager.removeItem(at: path.fileUrl)
    }
}
