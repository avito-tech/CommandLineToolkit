import Foundation
import PathLib

public extension FileSystem {
    func systemFreeSize(for path: AbsolutePath) throws -> Int64 {
        try fileSystemProperties(forFileAtPath: path).systemFreeSize()
    }
}
