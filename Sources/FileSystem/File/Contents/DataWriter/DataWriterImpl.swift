import Foundation
import PathLib

public final class DataWriterImpl: DataWriter {
    private let directoryCreator: DirectoryCreator
    
    public init(
        directoryCreator: DirectoryCreator
    ) {
        self.directoryCreator = directoryCreator
    }
    
    public func write(
        data: Data,
        filePath: AbsolutePath,
        ensureDirectoryExists: Bool
    ) throws {
        if ensureDirectoryExists {
            try directoryCreator.ensureDirectoryExists(path: filePath)
        }
        
        try data.write(to: filePath.fileUrl, options: .atomic)
    }
}
