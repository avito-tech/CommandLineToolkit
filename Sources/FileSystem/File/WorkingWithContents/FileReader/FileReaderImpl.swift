import Foundation
import PathLib

public final class FileReaderImpl: FileReader {
    public enum Errors: Error, CustomStringConvertible {
        case noContent(filePath: AbsolutePath)
        
        public var description: String {
            switch self {
            case let .noContent(filePath):
                return "Content not found for file at \(filePath)"
            }
        }
    }
    
    private let fileManager = FileManager()
    
    public init() {
    }
    
    public func contents(filePath: AbsolutePath) throws -> Data {
        guard let content = fileManager.contents(atPath: filePath.pathString) else {
            throw Errors.noContent(filePath: filePath)
        }
        return content
    }
}
