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
    
    public func decodable<T: Decodable>(
        jsonFilePath: AbsolutePath
    ) throws -> T {
        return try JSONDecoder().decode(
            T.self,
            from: contents(filePath: jsonFilePath)
        )
    }
}
