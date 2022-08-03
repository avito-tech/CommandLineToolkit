import Foundation
import PathLib

public protocol DataWriter {
    func write(
        data: Data,
        filePath: AbsolutePath,
        ensureDirectoryExists: Bool
    ) throws
}

extension DataWriter {
    public func write(
        data: Data,
        filePath: AbsolutePath
    ) throws {
        try write(
            data: data,
            filePath: filePath,
            ensureDirectoryExists: true
        )
    }
    
    public func write(
        string: String,
        filePath: AbsolutePath,
        ensureDirectoryExists: Bool = true
    ) throws {
        try write(
            data: Data(string.utf8),
            filePath: filePath,
            ensureDirectoryExists: ensureDirectoryExists
        )
    }
    
    public func writeJson<T: Encodable>(
        encodable: T,
        filePath: AbsolutePath,
        ensureDirectoryExists: Bool = true
    ) throws {
        try write(
            data: JSONEncoder().encode(encodable),
            filePath: filePath,
            ensureDirectoryExists: ensureDirectoryExists
        )
    }
}
