import Foundation
import PathLib

public enum ErrnoError: Error, CustomStringConvertible {
    case failedToCreateTemporaryFolder(AbsolutePath, code: Int32)
    case failedToCreateTemporaryFile(AbsolutePath, code: Int32)
    
    public var description: String {
        switch self {
        case let .failedToCreateTemporaryFolder(template, code):
            return "Failed to create temporary directory with template \(template), error code: \(code)"
        case let .failedToCreateTemporaryFile(template, code):
            return "Failed to create temporary file with template \(template), error code: \(code)"
        }
    }
}

public struct UnknownCanonicalPath: Error, CustomStringConvertible {
    let path: String
    
    public var description: String {
        return "Failed to determine canonical path for \(path)"
    }
}
