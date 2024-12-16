import CLTExtensions
import Foundation
import PathLib

public protocol FileReader {
    func contents(filePath: AbsolutePath) throws -> Data
}

extension FileReader {
    public func string(filePath: AbsolutePath) throws -> String {
        return try String(utf8Data: contents(filePath: filePath))
    }
    
    public func decodable<T: Decodable>(
        type: T.Type = T.self,
        jsonFilePath: AbsolutePath,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        try decoder.decode(type, from: contents(filePath: jsonFilePath))
    }
}
