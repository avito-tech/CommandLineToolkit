import Foundation
import PathLib
import String

public protocol FileReader {
    func contents(filePath: AbsolutePath) throws -> Data
}

extension FileReader {
    public func string(filePath: AbsolutePath) throws -> String {
        return try String(utf8Data: contents(filePath: filePath))
    }
}
